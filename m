From: Neil Brown <neilb@suse.de>
Subject: Re: Autofs-mounted NFS directories disappearing
Date: Tue, 11 Oct 2005 11:30:32 +1000
Message-ID: <17227.5560.451453.95349@cse.unsw.edu.au>
References: <6.2.1.2.2.20051010141020.05b86a00@mail.enuclia.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1EP8ym-0006pP-NK
	for nfs@lists.sourceforge.net; Mon, 10 Oct 2005 18:30:56 -0700
Received: from ns2.suse.de ([195.135.220.15] helo=mx2.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1EP8z0-0007bg-KO
	for nfs@lists.sourceforge.net; Mon, 10 Oct 2005 18:31:12 -0700
To: "John Medway, Enuclia Semiconductor" <john.medway@enuclia.com>
In-Reply-To: message from John Medway, Enuclia Semiconductor on Monday October 10
Sender: nfs-admin@lists.sourceforge.net
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

On Monday October 10, john.medway@enuclia.com wrote:
> Intermittently, sub directories of people's home dirs go bad on some of my 
> clients and report stale NFS handles when the user tries to access the 
> directory. Sometimes when this occurs, the subdir has been accessed in the 
> last few minutes. Sometimes, not for days (and it's just still mounted 
> because they have a shell sitting in it).
> 
> It's usually a couple of levels down, say ~foo/a/b/c and "c" will go stale. 
> If you're in it with a shell you get Stale NFS handle. If you're in "b" and 
> do an ls, "c" doesn't appear. If the missing/stale dir "c" is listed on 
> another machine, or on the server, it usually immediately goes un-stale on 
> the problem box.
> 
> Thoughts?
..
> Server:
>          Redhat 2.6.9-5.ELsmp #1 SMP
>                  Wed Jan 5 19:30:39 EST 2005 i686 athlon i386 GNU/Linux

There was a bug in ext3 that was fixed later than this date which
could be your problem.
It was related to the 'dir_index' feature of ext3.
So: 
  if you are using ext3
    and you have dir_index enabled (tune2fs -l /dev/xxx should tell
      you).
  then
    try turning off dir_index
           tune2fs -O ^dir_index /dev/xxxx
         and then remount
    and see if that fixes it.

Or just try a newer kernel.

NeilBrown


-------------------------------------------------------
This SF.Net email is sponsored by:
Power Architecture Resource Center: Free content, downloads, discussions,
and more. http://solutions.newsforge.com/ibmarch.tmpl
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
