From: Peter Staubach <staubach@redhat.com>
Subject: Re: cannot remove silly renamed files
Date: Tue, 19 Sep 2006 13:46:51 -0400
Message-ID: <45102D0B.5080202@redhat.com>
References: <5FD3925640200143AA51A2F603FEB86A02258293@gsmbnmp19es.firmwide.corp.gs.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GPjgR-0005VL-KQ
	for nfs@lists.sourceforge.net; Tue, 19 Sep 2006 10:46:59 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1GPjgS-0001Tk-5z
	for nfs@lists.sourceforge.net; Tue, 19 Sep 2006 10:47:00 -0700
To: "Topp, Kenneth" <Kenneth.Topp@gs.com>
In-Reply-To: <5FD3925640200143AA51A2F603FEB86A02258293@gsmbnmp19es.firmwide.corp.gs.com>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

Topp, Kenneth wrote:
>
> Hi,
>
> I've searched the archive but didn't find anything related.  2.6 
> doesn't allow you to delete .nfsXXX (silly renamed) files from the 
> host that has it open.  2.4 and solaris 2.X has allowed one to shoot 
> oneself in the foot.
>
> Can we update the code to do a rename twice then allow removal rather 
> then blocking it indefinitely?  The current code changes breaks expect 
> commands like "/bin/rm -rf dir/", which I'm sure is defined somewhere 
> in POSIX.
>

Actually, I don't think that Solaris allows the .nfs temporary files to be
removed either.  The unlink(2) system call may not fail, but all that the
client does is to rename the file to a new .nfs temporary name.

Part of the danger of allowing these files to be really removed is, as you
say, to allow you to shoot yourself in the foot.  However, it would also
allow someone else to shoot you in the foot, which wouldn't be so good.

I might suggest rearchitecting the solution which depends upon things like
"rm -fr dir" to work by renaming "dir" to something else and then 
proceeding.

       ps

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys -- and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
