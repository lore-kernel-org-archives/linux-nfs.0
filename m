From: dwight@supercomputer.org
Subject: Re: RE: Linux client on Solaris 7 NFS server
Date: Mon, 05 Jan 2004 23:41:17 -0800
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <200401060741.i067fHw16909@supercomputer.org>
References: <wade.hampton@nsc1.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.24)
	id 1Adlq4-0001h4-S1
	for nfs@lists.sourceforge.net; Mon, 05 Jan 2004 23:41:20 -0800
Received: from supercomputer.org ([69.17.34.169] helo=mail.supercomputer.org)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.30)
	id 1Adlq4-0006yi-Fc
	for nfs@lists.sourceforge.net; Mon, 05 Jan 2004 23:41:20 -0800
To: Wade Hampton <wade.hampton@nsc1.net>
In-Reply-To: Message from Wade Hampton <wade.hampton@nsc1.net>
   of "Mon, 05 Jan 2004 14:46:04 EST." <3FF9BEFC.6030609@nsc1.net>
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

Hi Wade,

I haven't seen such behaviour myself, but I do remember some bugid's
which seem related. Basically, as I mentioned before, you need to go to
sun.com, and run their patch expert tool. Use the web-based java applet;
avoid their java-based CLI technology - there are too many problems
with it, and it is basically useless IMHO.

Then just select the patches that you need, download the tarball,
extract it, and run the patching tool. It's pretty straightforward
if you do it by hand. Just be *certain* to do a `boot -r` right
afterwards if the README says to reboot the system.

Specifically, I recall seeing a big kernel-level patch related to NFS
hanging issues.

You can tell what level your kernel is patched to via `uname -a` on
Solaris IIRC. In general, if you have an older stock Solaris release,
you need to patch it.

Regards,

        -dwight-




-------------------------------------------------------
This SF.net email is sponsored by: IBM Linux Tutorials.
Become an expert in LINUX or just sharpen your skills.  Sign up for IBM's
Free Linux Tutorials.  Learn everything from the bash shell to sys admin.
Click now! http://ads.osdn.com/?ad_id=1278&alloc_id=3371&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
