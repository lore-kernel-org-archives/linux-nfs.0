From: Peter Staubach <staubach@redhat.com>
Subject: Re: [NFS] NFS Question
Date: Fri, 30 Jan 2009 16:17:23 -0500
Message-ID: <49836E63.8080406@redhat.com>
References: <ba5a5c3c0901301312i1fddde72la73e1b72b8af94d@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: Scott Corley <scorley20@gmail.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from neil.brown.name ([220.233.11.133]:36827 "EHLO neil.brown.name"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754189AbZA3VRy (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 30 Jan 2009 16:17:54 -0500
Received: from brown by neil.brown.name with local (Exim 4.69)
	(envelope-from <nfs-bounces@lists.sourceforge.net>)
	id 1LT0kK-0002Xj-MG
	for linux-nfs@vger.kernel.org; Sat, 31 Jan 2009 08:17:52 +1100
In-Reply-To: <ba5a5c3c0901301312i1fddde72la73e1b72b8af94d-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Scott Corley wrote:
> Hey,
>  
> I'm trying to set up NFS version 3 on my computer with several cients. 
> I figured I would get it working between two computers to verify it's 
> functioning then extend it to the rest.  I follow all steps of the 
> "Linux NFS-HOWTO" exactly but I am getting some issues when I try to 
> mount.  On every try I get RPC-timeout and don't know what is causing 
> it.  I am able to ping from host to client and vice versa so it's not 
> a network issue.  I would appreciate some help on this matter.
>  
> Thanks,
> Scott
>  
> nfs-utils package version 1.0.1-2.9
> kernal version 2.4.20-6smp
> Redhat, Linux 9
> all other clients are the same
>  
> /etc/exports
> /home   xxx.xxx.xx.xx(rw,sync)
>  
>  
>  
> rpcinfo (host)
> program    vers     proto        port
>                 tcp         111    portmapper
>                 udp        111    portmapper
>                 tcp       32768   sgi_farm
>                 udp       2049    nfs
>                 udp       2049    nfs
>                 udp      32957   nlockmgr
>                 udp      32957   nlockmgr
>                 udp      32957   nlockmgr
>                 udp      33109   mountd
>                 tcp       49158   mountd
>                 udp      33109   mountd
>                 tcp       49158   mountd
>                 udp      33109   mountd
>                 tcp       49158   mountd
>                 udp         976   rquotad
>                 udp         976   rquotad
>                 tcp          976   rquotad
>                 tcp          976   rquotad
>                 udp      33126   status
>                 tcp       49195   status
>  
>  
>  
> rpcinfo (server)
> program    vers    proto     port
>                   2         111   portmapper
>                   2         111   portmapper
>                   2       3279   sgi_farm
>                   1      32771  status
>                   1      38232  status

Wow!  Old Red Hat.  :-)

You need mountd and nfsd running on the server, not on the client,
right?

    Thanx...

       ps

------------------------------------------------------------------------------
This SF.net email is sponsored by:
SourcForge Community
SourceForge wants to tell your story.
http://p.sf.net/sfu/sf-spreadtheword
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
_______________________________________________
Please note that nfs@lists.sourceforge.net is being discontinued.
Please subscribe to linux-nfs@vger.kernel.org instead.
    http://vger.kernel.org/vger-lists.html#linux-nfs

