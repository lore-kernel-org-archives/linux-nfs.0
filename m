From: "ian sison (mailing list)" <ian.s@qsr.com.ph>
Subject: Re: Reserving port 800 on linux NFS clients
Date: Wed, 17 Mar 2004 13:50:08 +0800 (PHT)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.LNX.4.33L2.0403171349300.20810-100000@jeprox.qsr.com.ph>
References: <o8lf50t2d4junli54us281h0i7433pl5lr@4ax.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1B3Tto-00024r-78
	for nfs@lists.sourceforge.net; Tue, 16 Mar 2004 21:47:28 -0800
Received: from [202.8.246.187] (helo=jeprox.qsr.com.ph ident=qzwtan)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.30)
	id 1B3Ttm-0000qj-Ft
	for nfs@lists.sourceforge.net; Tue, 16 Mar 2004 21:47:26 -0800
Received: from localhost (localhost [127.0.0.1])
	by jeprox.qsr.com.ph (Postfix) with ESMTP id 4145C3BFD1
	for <nfs@lists.sourceforge.net>; Wed, 17 Mar 2004 13:50:09 +0800 (PHT)
Received: from jeprox.qsr.com.ph ([127.0.0.1])
 by localhost (jeprox.qsr.com.ph [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id 07886-02 for <nfs@lists.sourceforge.net>;
 Wed, 17 Mar 2004 13:50:08 +0800 (PHT)
Received: from localhost (localhost [127.0.0.1])
	by jeprox.qsr.com.ph (Postfix) with ESMTP id B32663BF76
	for <nfs@lists.sourceforge.net>; Wed, 17 Mar 2004 13:50:08 +0800 (PHT)
To: <nfs@lists.sourceforge.net>
In-Reply-To: <o8lf50t2d4junli54us281h0i7433pl5lr@4ax.com>
Errors-To: nfs-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>


I think http://www.lowth.com/LinWiz/nfs_help.html would be helpful in
this.


On Tue, 16 Mar 2004, Errol Casey wrote:

> Recently, I've run into an issue where my Linux NFS clients are using
> port 800 to communicate with NFSd daemons running on an Netapp Filer.
>
> Is there any way to configure the Linux NFS client software to not use
> port 800. Looking at the ports in use on my clients, it looks as if a
> series of ports 797-800 are used to communicate to nfsd.
>
> I would like to use port 800 for another daemon. On a few machines,
> this conflict does not occur.
>
>
>
>
>
> -------------------------------------------------------
> This SF.Net email is sponsored by: IBM Linux Tutorials
> Free Linux tutorial presented by Daniel Robbins, President and CEO of
> GenToo technologies. Learn everything from fundamentals to system
> administration.http://ads.osdn.com/?ad_id=1470&alloc_id=3638&op=click
> _______________________________________________
> NFS maillist  -  NFS@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/nfs
>
>



-------------------------------------------------------
This SF.Net email is sponsored by: IBM Linux Tutorials
Free Linux tutorial presented by Daniel Robbins, President and CEO of
GenToo technologies. Learn everything from fundamentals to system
administration.http://ads.osdn.com/?ad_id=1470&alloc_id=3638&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
