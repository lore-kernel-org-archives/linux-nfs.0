Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp.ctxuk.citrix.com ([185.25.65.24]:60807 "EHLO
        SMTP.EU.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752572AbcJMJ3a (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 13 Oct 2016 05:29:30 -0400
From: Stefano Panella <stefano.panella@citrix.com>
To: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Subject: Possible regression on NSFv3/sunrpc timeouts when using
 NFS_CS_DISCRTRY
Date: Thu, 13 Oct 2016 09:29:27 +0000
Message-ID: <294b7f15dea745818d91ad9eab16a30b@AMSPEX02CL03.citrite.net>
Content-Type: text/plain; charset="iso-8859-1"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi all,

I think there has been a change in the net/sunrpc code introduced with 

commit 9cbc94fb06f98de0e8d393eaff09c790f4c3ba46
Author: Trond Myklebust <trond.myklebust@primarydata.com>
Date:   Sun Feb 8 15:50:27 2015 -0500

    SUNRPC: Remove TCP socket linger code

    Now that we no longer use the partial shutdown code when closing the
    socket, we no longer need to worry about the TCP linger2 state.

    Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>

which has caused some regressions removing the functionality which was mentioned 
in the email thread I have attached below.

We have exactly the same use case as the one in the email thread. We call
    __set_bit(NFS_CS_DISCRTRY, &clp->cl_flags)
also in NSFv3

which means we have been relying on the lingering_timeout code to disconnect
and be able to reconnect quickly if the client IP suddenly changes.

As we stand, before moving to 4.4. kernel, where lingering_timeout functionality 
has been removed, we were able to talk again with the NFSv3 share in 60 + 15 seconds
(XS_TCP_LINGER_TO = 15 seconds) while now, after the commit above,  
we need 60 + 924 seconds.

This is because we are keeping the global /proc/sys/net/ipv4/tcp_retries2 = 15 as it is by 
default and we would not want to risk to change it to something else.

I have two questions:

1) Can we say removing the lingering_timeout functionality caused a regression?
2) Is there any way this could be fixed reintroducing it or putting a new mechanism in place
so we can talk to the share using a new connection before the previous (with the old IP) times
out with tcp_retries2 after 15 minutes?

Please have a look at the thread I have included below and let me know what do you think
about this problem.

If you can recommend a way you would like this to be addressed, I would be happy to 
contribute a patch.

Thanks everyone,

Stefano


THREAD I AM REFERRING TO:
----------------------------------------------------------------------------------------------------------------------

On Wed, 24 Sep 2014 16:39:55 +0100 Benjamin ESTRABAUD <be@xxxxxxxxxx> wrote:

> Hi!
> 
> I've got a scenario where I'm connected to a NFS share on a client, have 
> a file descriptor open as read only (could also be write) on a file from 
> that share, and I'm suddenly changing the IP address of that client.
> 
> Obviously, the NFS share will hang, so if I now try to read the file 
> descriptor I've got open (here in Python), the "read" call will also hang.
> 
> However, the driver seems to attempt to do something (maybe 
> save/determine whether the existing connection can be saved) and then, 
> after about 20 minutes the driver transparently reconnects to the NFS 
> share (which is what I wanted anyways) and the "read" call instantiated 
> earlier simply finishes (I don't even have to re-open the file again or 
> even call "read" again).
> 
> The dmesg prints I get are as follow:
> 
> [ 4424.500380] nfs: server 10.0.2.17 not responding, still trying <-- 
> changed IP address and started reading the file.
> [ 4451.560467] nfs: server 10.0.2.17 OK <--- The NFS share was 
> reconnected, the "read" call completes successfully.

The difference between these timestamps is 27 seconds, which is a lot less
than the "20 minutes" that you quote.  That seems odd.

If you adjust
   /proc/sys/net/ipv4/tcp_retries2

you can reduce the current timeout.
See Documentation/networking/ip-sysctl.txt for details on the setting.

https://www.kernel.org/doc/Documentation/networking/ip-sysctl.txt

It claims the default gives an effective timeout of 924 seconds or about 15
minutes.

I just tried and the timeout was 1047 seconds. This is probably the next
retry after 924 seconds.

If I reduce tcp_retries2 to '3' (well below the recommended minimum) I get
a timeout of 5 seconds.
You can possibly find a suitable number that isn't too small...

Alternately you could use NFSv4.  It will close the connection on a timeout.
In the default config I measure a 78 second timeout, which is probably more
acceptable.  This number would respond to the timeo mount option.
If I set that to 100, I get a 28 second timeout.

The same effect could be provided for NFSv3 by setting:

           __set_bit(NFS_CS_DISCRTRY, &clp->cl_flags);

somewhere appropriate.  I wonder why that isn't being done for v3 already...
Probably some subtle protocol difference.

NeilBrown

 
> I would like to know if there was any way to tune this behaviour, 
> telling the NFS driver to reconnect if a share is unavailable after say 
> 10 seconds.
> 
> I tried the following options without any success:
> 
> retry=0; hard/soft; timeo=3; retrans=1; bg/fg
> 
> I am running on a custom distro (homemade embedded distro, not based on 
> anything in particular) running stock kernel 3.10.18 compiled for i686.
> 
> Would anyone know what I could do to force NFS into reconnecting a 
> seemingly "dead" session sooner?
> 
> Thanks in advance for your help.
> 
> Regards,
> 
> Ben - MPSTOR.