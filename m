From: Spencer Shepler <shepler@eng.sun.com>
Subject: Re: NFS Server Interoperability: Link and Rename
Date: Thu, 3 Oct 2002 12:33:49 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20021003173349.GO105517@sheplerathome.eng.sun.com>
References: <20021001013922.23147.qmail@web13207.mail.yahoo.com>
Reply-To: spencer.shepler@sun.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from nwkea-mail-2.sun.com ([192.18.42.14])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17x9sq-00072R-00
	for <nfs@lists.sourceforge.net>; Thu, 03 Oct 2002 10:35:32 -0700
To: Jonathan Nicklin <jnicklin111@yahoo.com>
In-Reply-To: <20021001013922.23147.qmail@web13207.mail.yahoo.com>
Errors-To: nfs-admin@lists.sourceforge.net
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchives/forum.php?forum=nfs>

On Mon, Jonathan Nicklin wrote:
> 
> All,
> 
> Over the last decade, there seems to have been quite a bit of discussion about whether NFS filehandles (V2/V3) are allowed to change as a result of a link or rename operation. Its appears that Linux includes the parent inode as part of the filehandle and while this does not appear to be in violation of the spec (depending on who you talk to), Im curious if anyone has noticed interoperability problems with clients on other platforms that are a result of server behavior as described above. For example, how does the Solaris v7/v8 client deal with such behavior. Its obvious that renames in the same directory would be fine, but what about cross directory renames and links?
> 

If the client/application has the file open at the time of the rename,
it will break.  The filehandle will become stale (this assumes the
server isn't doing some type of mapping to protect the client a
little) and with stale filehandles the client has no way to recover.

If the file is not open at the time of rename, the failure would
depend on how the client is coded to handle receiving a stale error
from a cached filehandle (cached in the client's name cache more than
likely).  This failure would be less determinant.

This type of server behavior is frowned upon and NFSv4 offers a
partial solution to the problem.

-- 
Spencer



-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
