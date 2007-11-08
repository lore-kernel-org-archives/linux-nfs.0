From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: NFS Causing issues with Gimp XCF files?
Date: Thu, 8 Nov 2007 17:02:34 -0500
Message-ID: <20071108220234.GH1813@fieldses.org>
References: <20071108215404.GA8331@apocalyptech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: CJ Kucera <pez@apocalyptech.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IqFSJ-0006uM-Nk
	for nfs@lists.sourceforge.net; Thu, 08 Nov 2007 14:02:31 -0800
Received: from mail.fieldses.org ([66.93.2.214] helo=fieldses.org)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IqFSO-0004Jm-WA
	for nfs@lists.sourceforge.net; Thu, 08 Nov 2007 14:02:37 -0800
In-Reply-To: <20071108215404.GA8331@apocalyptech.com>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

On Thu, Nov 08, 2007 at 03:54:04PM -0600, CJ Kucera wrote:
> I've been encountering a problem on my Linux machine running Gimp 2.4.1 [1]
> where XCF files that I save are occasionally corrupt, and can't be
> loaded again into the same program.  I'm 99% sure that this is something
> NFS-related, since this problem occurs only on my NFS shares, and never
> when I'm saving to my local hard drive.  I noticed this problem in Gimp
> 2.4.0 as well (it may have been happening in some of the 2.3 development
> versions as well, though I didn't notice).
> 
> Mostly right now I'd just like to find somebody other than me who can
> reproduce the problem.  I've put some files up at
> http://apocalyptech.com/media/gimp/ -
> 
>   * goinonboat.xcf - a Gimp file saved in an earlier version of Gimp
>   * goinonboat2.xcf - The same file, after I've saved to an NFS share
>   * dimension.png - The binary differences between the two files.
> 
> ... so if somebody has Gimp 2.4.0 or 2.4.1 available, would you mind
> loading up goinonboat.xcf, saving it to an NFS share, and then try to
> have Gimp re-open the image?
> 
> It's interesting (to me) to note that the differences are all in the
> width/height/bpp values writen by gimp's xcf_save_hierarchy() function
> from app/xcf/xcf-save.c.  [2] Instead of writing the correct
> width/height/bpp values, it ends up being zeros when the file is finally
> closed.  I've added in various debugging statements, and loaded up a
> debug build of gimp into gdb to trace through, and in all cases, the
> values being passed into the actual fwrite() calls are correct -
> something ends up writing them inappropriately in the end, though.
> 
> There *is* some fseek()ing going on during that part of the save
> process, and I've found that the situation improves (though not
> completely) when I start throwing in fflush() statements - so far, with
> liberal use of fflush() I've been able to make it so that only the
> "width" parameter ends up being zero.
> 
> Both the NFS server and my client machine (where I'm running gimp) are
> running vanilla 2.6.23.1 kernels, and nfs-utils 1.1.0.

Have you seen this?:

	http://bugzilla.kernel.org/show_bug.cgi?id=9315

--b.

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
