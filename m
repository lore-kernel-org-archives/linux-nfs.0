From: Andrew Ryan <andrewr@nam-shub.com>
Subject: Re: 3 bugs with UDP mounts
Date: Tue, 23 Apr 2002 09:28:31 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <5.0.2.1.0.20020423092524.024733a0@pop.sfrn.dnai.com>
References: <5.0.2.1.0.20020422235308.02a960b0@pop.sfrn.dnai.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; format=flowed
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from smithers.sfrn.dnai.com ([208.59.199.26])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17039L-0006Va-00
	for <nfs@lists.sourceforge.net>; Tue, 23 Apr 2002 09:28:15 -0700
To: Ion Badulescu <ionut@cs.columbia.edu>
In-Reply-To: <200204231520.g3NFK2A04858@buggy.badula.org>
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

At 11:20 AM 4/23/02 -0400, Ion Badulescu wrote:
>On Tue, 23 Apr 2002 00:37:15 -0700, Andrew Ryan <andrewr@nam-shub.com> wrote:
> > Solaris has clearly solved this problem somehow -- it would be nice if
> > linux could as well.
>
>Are you absolutely sure that Solaris is mounting NFS/UDP? The reason I'm
>asking is because Solaris' mount_nfs defaults to using TCP unless you
>explicitly force it to use UDP with -o proto=udp.


Yes, indeed, I did mount the server with the 'proto=udp' option on the 
Solaris host.



thanks,
andrew


_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
