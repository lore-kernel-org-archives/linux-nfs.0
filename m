From: "Steven N. Hirsch" <shirsch@adelphia.net>
Subject: Re: nfs-utils/lockd problems
Date: Fri, 19 Jul 2002 18:13:46 -0400 (EDT)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.LNX.4.44.0207191812340.3031-100000@atx.fast.net>
References: <1027100709.25617.166.camel@k2x>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "nfs@lists.sourceforge.net" <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from smtprelay9.dc2.adelphia.net ([64.8.50.53])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17Vg0c-0007f6-00
	for <nfs@lists.sourceforge.net>; Fri, 19 Jul 2002 15:13:59 -0700
To: Kashif Shaikh <kshaikh@consensys.com>
In-Reply-To: <1027100709.25617.166.camel@k2x>
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
List-Archive: <http://www.geocrawler.com/redir-sf.php3?list=nfs>

On 19 Jul 2002, Kashif Shaikh wrote:

> Hello everyone,
> 
> I'm encountering unmount issues with lockd on stock 2.4.18 kernels.  The
> problem:
> 

I was experiencing all sorts of badness with my mail spool on an NFS 
mounted filesystem.  Upgrading the server to 2.4.19-rc1-ac3 seems to have 
done the trick.  All gone!

Steve




-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
