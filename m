From: dwight@supercomputer.org
Subject: Re: RE: Linux client on Solaris 7 NFS server
Date: Mon, 05 Jan 2004 23:38:17 -0800
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <200401060738.i067cHF16900@supercomputer.org>
References: <Charles.Lever@netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.24)
	id 1Adln9-0001bI-WA
	for nfs@lists.sourceforge.net; Mon, 05 Jan 2004 23:38:19 -0800
Received: from supercomputer.org ([69.17.34.169] helo=mail.supercomputer.org)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.30)
	id 1Adln9-0006NS-Mk
	for nfs@lists.sourceforge.net; Mon, 05 Jan 2004 23:38:19 -0800
Received: (from watcher@localhost)
	by mail.supercomputer.org (8.11.6/8.11.6) id i066UcB20625
	for <nfs@lists.sourceforge.net>; Mon, 5 Jan 2004 22:30:38 -0800 (PST)
To: nfs@lists.sourceforge.net
In-Reply-To: Message from "Lever, Charles" <Charles.Lever@netapp.com>
   of "Mon, 05 Jan 2004 10:21:59 PST." <482A3FA0050D21419C269D13989C6113020AC981@lavender-fe.eng.netapp.com>
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

Hi Charles,

I actually have lots of data on this, since I ran tcpdump on every major
run when I was gathering data. Each tcpdump output file is about 20 MB.

That's the good news. =


The bad news is I don't know if I can release that specific data. My =

guess is that I'll have to cut over to a totally isolated subnet and =

rerun things. =


However, if such data can be released, and if there's enough interest in
looking the tcpdump output, I'd be willing to go to the efforts of doing =

so for those who'd be interested in looking at the tcpdump data.

So I'll investigate further. =


Best Regards,

	-dwight-

From: "Lever, Charles" <Charles.Lever@netapp.com>
Date: Mon, 5 Jan 2004 10:21:59 -0800
> hi dwight-
> =

> please capture some network traces of both a fast run and
> a slow run (using UDP for both, preferrably).  the traces
> don't need to be large (in the neighborhood of 10MB), but
> they do need to be raw format, and be sure you capture
> at least 256 bytes of each frame (-s256).
> =

> the v2/v3 performance delta is usually a red herring; it
> is almost always the result of some other problem.
> =





-------------------------------------------------------
This SF.net email is sponsored by: IBM Linux Tutorials.
Become an expert in LINUX or just sharpen your skills.  Sign up for IBM's
Free Linux Tutorials.  Learn everything from the bash shell to sys admin.
Click now! http://ads.osdn.com/?ad_id=1278&alloc_id=3371&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
