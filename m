From: Mathieu Chouquet-Stringer <mathieu@newview.com>
Subject: Re: Re[2]: NFS Performance
Date: 18 Apr 2002 19:48:54 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <xlt7kn47el5.fsf@shookay.newview.com>
References: <6440EA1A6AA1D5118C6900902745938E50CEA5@black.eng.netapp.com>
	<85858198133.20020418230924@netzone.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from esteel10.client.dti.net ([209.73.14.10] helo=shookay.newview.com)
	by usw-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 16yLeC-0002Ee-00
	for <nfs@lists.sourceforge.net>; Thu, 18 Apr 2002 16:49:04 -0700
To: gavin.woodhatch@netzone.ch (Gavin Woodhatch)
In-Reply-To: <85858198133.20020418230924@netzone.ch>
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

gavin.woodhatch@netzone.ch (Gavin Woodhatch) writes:
> Hi Charles
> 
> > what's your backup media?  your tape drive may be the
> > real bottleneck.
> 
> Its a 100 GB LTO (Ultrium) Tape Drive from HP. But even "tar cf
> /dev/null /mnt" is not faster ..

If tar is also slow, try with bigger blocks (by default tar reads/writes
using blocks that are 20x512 bytes and on one of my servers it is not fast
enough to make a DLT tape streaming).

man tar (-b --block-size)

-- 
Mathieu Chouquet-Stringer              E-Mail : mathieu@newview.com
    It is exactly because a man cannot do a thing that he is a
                      proper judge of it.
                      -- Oscar Wilde

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
