From: Daniel Gryniewicz <dang@fprintf.net>
Subject: Re: NFS not running !!!
Date: Wed, 24 Apr 2002 10:36:06 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20020424103606.38bf876a.dang@fprintf.net>
References: <DAV48guA8M6XQQez1en000011fe@hotmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from addr-mx01.addr.com ([209.249.147.145])
	by usw-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 170Nsf-0004An-00
	for <nfs@lists.sourceforge.net>; Wed, 24 Apr 2002 07:36:25 -0700
To: "Tina Arora" <tinaarora@hotmail.com>
In-Reply-To: <DAV48guA8M6XQQez1en000011fe@hotmail.com>
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

On Wed, 24 Apr 2002 13:08:54 +0530
"Tina Arora" <tinaarora@hotmail.com> wrote:

> Hello friends thanx so much 4 replying to my yesterday's  query.
> heres 1 more..
> I downloaded nfs-utils-0.3.3 and executed all the four commands
>  #./configure
> # make
> #make install
> #rpm -ta nfs-utils-0.3.3.tar.gz
> everything went fine but when i tried to verify NFS with rpcinfo -p command
I got only 4 lines in the output (2 for portmap and 2 for status)> and none
for rquotad or mountd or nfs or amd or nlockmgr..> Readme of this nfs utility
says that to build the source & binary RPMs, mount in util-linux 2.11f or
above is required ..> I have a mount version of 2.11b ...
> Can the above problem be caused coz of mount version problem..
> please help me out..
> other nfs-utilities say u shud not have a too old mount version ...what is
meant by too old mount version.. please try to be specific..> thanx n bye
> Tina
> 

A default build will put the binaries in /usr/local/bin, while the original
binaries are likely in /sbin or /usr/sbin, which are almost certainly before
/usr/local/bin in your path.  So, if you just run them from the command line,
you will probably get the old ones. Try either using the full path
(/usr/local/bin/rpcinfo or /usr/local/sbin/rpcinfo) or reinstalling in the
same location as the original utilities.

Daniel
--- 
Recursion n.:
        See Recursion.
                        -- Random Shack Data Processing Dictionary


_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
