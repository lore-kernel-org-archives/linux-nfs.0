Return-Path: linux-nfs-owner@vger.kernel.org
Received: from nm17-vm0.access.bullet.mail.mud.yahoo.com ([66.94.236.21]:48608
	"HELO nm17-vm0.access.bullet.mail.mud.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1752870Ab1LLSQh convert rfc822-to-8bit
	(ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 12 Dec 2011 13:16:37 -0500
Message-ID: <1323713796.6172.YahooMailClassic@web181402.mail.ne1.yahoo.com>
Date: Mon, 12 Dec 2011 10:16:36 -0800 (PST)
From: John Simon <tzzhc4@yahoo.com>
Subject: Re: Intermittent performance issues with Solaris 10 NFS V3 client to RHEL 5.5 NFS server
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org
In-Reply-To: <20111212161348.GG18185@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I had opened a case with SUN/Oracle and send trace and snoop output. Their comment was the issue was response from the Linux side.

>     - Anything interesting in the logs on
> client or server?

No error messages or anything intersting in the logs on either server. 

>     - If you look at a small part of the
> network traffic in
>       wireshark, in the bad case, is
> there any obvious problem?
>       (Lots of retransmissions, errors
> returned from the server, ?)

Looked at numerous tcpdump and snoop and don't see any appreciable errors or retransmissions. Also do not see any congestion control coming into play (tcp window is still very open 40k-65k and no pause frames at the ethernet layer).


>     - Can you get any rpc statistics out of
> the client?  (Average
>       time to respond to an rpc, mix of
> rpc's sent, etc.?)

I need to look at rpc stats on the client.

I received a couple off list replies from other users who mentioned they encountered similar issues and upgrading their kernel helped (one user was on 5.5 and went to 5.6 and another was running Debian). If anyone knows of any issues with 2.6.18-194.el5 nfs-utils-1.0.9-44.el5 that could cause intermittent performance for NFS I would appreciate it.



--- On Mon, 12/12/11, J. Bruce Fields <bfields@fieldses.org> wrote:

> From: J. Bruce Fields <bfields@fieldses.org>
> Subject: Re: Intermittent performance issues with Solaris 10 NFS V3 client to RHEL 5.5 NFS server
> To: "John Simon" <tzzhc4@yahoo.com>
> Cc: linux-nfs@vger.kernel.org
> Date: Monday, December 12, 2011, 10:13 AM
> On Sun, Dec 11, 2011 at 12:00:45PM
> -0800, John Simon wrote:
> > I recently attached a Solaris 10 8/07 client (6900
> with ce gigbit
> > interface) to our NFS server which runs RHEL 5.5
> (kernel
> > 2.6.18-194.el5).
> 
> Could you file a bug against Red Hat and/or Solaris?
> 
> > Performance typically is good running around
> > 25-50MB/s but sometimes seemingly without reason the
> performance drops
> > to abysmal levels and will stay like that until NFS is
> unmounted and
> > remounted. I have tested this after hours when there
> is no load on
> > either server, no traffic on the network and using a
> 1GB test file.
> > Our other 300 Linux clients have no performance
> issues, I have ruled
> > out network issues by isolating the server to a switch
> dedicated to it
> > and an additional port on the NFS server and the tests
> I performed
> > were with the file cache in memory.
> > 
> > $ time cp /var/tmp/1g.TEST.new /mnt/ real   
> 25m1.456s user
> > 0m0.276s sys     0m6.699s
> > 
> > After an unmount, wait 5 minutes and remount:
> > 
> > $ time cp /var/tmp/1g.TEST.new /mnt/ real   
> 0m26.767s user
> > 0m0.277s sys     0m6.589s
> > 
> > Mount options I am using on Solaris:
> > 
> >   Flags:
> >   vers=3,proto=tcp,sec=none,hard,intr,link,symlink,acl,rsize=32768,wsize=32768,retrans=5,timeo=600
> >   Attr cache:   
> acregmin=120,acregmax=120,acdirmin=120,acdirmax=120
> 
> Some ideas:
> 
>     - Anything interesting in the logs on
> client or server?
>     - If you look at a small part of the
> network traffic in
>       wireshark, in the bad case, is
> there any obvious problem?
>       (Lots of retransmissions, errors
> returned from the server, ?)
>     - Can you get any rpc statistics out of
> the client?  (Average
>       time to respond to an rpc, mix of
> rpc's sent, etc.?)
> 
> --b.
> --
> To unsubscribe from this list: send the line "unsubscribe
> linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
