From: Rob Gardner <rob.gardner@hp.com>
Subject: Re: [NFS] Please help with NFS on Kubuntu Karmic 9.10
Date: Sat, 05 Dec 2009 13:38:58 -0700
Message-ID: <4B1AC4E2.10302@hp.com>
References: <4B1A9F49.4000606@mindspring.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: "nfs@lists.sourceforge.net" <nfs@lists.sourceforge.net>
To: Larry Alkoff <labradley@mindspring.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from neil.brown.name ([220.233.11.133]:44195 "EHLO neil.brown.name"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755287AbZLEUjy (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 5 Dec 2009 15:39:54 -0500
Received: from brown by neil.brown.name with local (Exim 4.69)
	(envelope-from <nfs-bounces@lists.sourceforge.net>)
	id 1NH1Q7-0006YU-VC
	for linux-nfs@vger.kernel.org; Sun, 06 Dec 2009 07:40:00 +1100
In-Reply-To: <4B1A9F49.4000606@mindspring.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Larry Alkoff wrote:
> I am unable to connect with Kubuntu netbook remix Karmic 9.10.
>
> I have seen many posts and articles on this issue.
>
> The problem seems to be centered around the nfs version being used
> and I have placed the following 2 lines in /etc/fstab:
>
> kata:/          /mnt/kata       nfs     defaults,noauto,nfsver=2  0 0
> kata:/home      /mnt/kata/home  nfs     defaults,noauto,nfsver=2  0 0
> kata is the netbook server which I am trying to mount on the client
> called arriba which runs on Kubuntu 8.04 LSB.
>
> Most of the posts I have read say to add 'nfsver-2' to the fstab lines.
> However on both client and server, cat /proc/filesystems |grep nfs
> shows only:
> nodev nfs
> nodev nfs4 and
> nodev nfsd.
>
> It seems that this problem appears when people upgrade to (K)ubuntu 9.10
> from an earlier version.  In my case, this is a new netbook and I loaded 
> the most recent version Kubuntu 9.10.  Efforts to load Kubuntu 8.04 LTS
> which I use on my other machines failed - possibly because of the 
> limited facilities on this small HP 110 Netbook.
>
> This result happens on both server kata and client arriba.
> I don't know that the 'nodev' means.
>
> I would like to add either nfs2 or nfs3 but have no idea how to specify
> this in apt-get or aptitude.
>
> I'd also like to add that I have used Linux desktops and nfs for years 
> (mostly on the command line) and believe it's setup correctly.
>
> Please I am requesting troubleshooting advice.
> It's getting really old to have to use a thumb drive to transfer files.
>
> Larryalk
>
>
>   

Just pointing out that you do not actually state what the problem is 
beyond "unable to connect". It might help if you described the symptoms 
a little further, ie, "I see mount error -13 on the console". For what 
it's worth, I think the "nodev" thing is a red herring; I see the same 
thing on my ubuntu server, and I can mount its exported filesystems just 
fine.


Rob Gardner

------------------------------------------------------------------------------
Join us December 9, 2009 for the Red Hat Virtual Experience,
a free event focused on virtualization and cloud computing. 
Attend in-depth sessions from your desk. Your couch. Anywhere.
http://p.sf.net/sfu/redhat-sfdev2dev
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
_______________________________________________
Please note that nfs@lists.sourceforge.net is being discontinued.
Please subscribe to linux-nfs@vger.kernel.org instead.
    http://vger.kernel.org/vger-lists.html#linux-nfs

