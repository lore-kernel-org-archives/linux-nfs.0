From: Tavis Barr <tb62@columbia.edu>
Subject: Re: tunneling of nfs and nfs locks
Date: 19 Mar 2002 10:37:49 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1016552269.2031.8.camel@vaio>
References: <20020319161229.B10434@zeus.centre-cired.fr>
Mime-Version: 1.0
Content-Type: text/plain
Cc: nfs@lists.sourceforge.net
Received: from 24-29-106-192.nyc.rr.com ([24.29.106.192] helo=localhost.localdomain)
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 16nLh9-0002Hn-00
	for <nfs@lists.sourceforge.net>; Tue, 19 Mar 2002 07:38:39 -0800
To: Dumas Patrice <dumas@centre-cired.fr>
In-Reply-To: <20020319161229.B10434@zeus.centre-cired.fr>
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


See the draft version of the HOWTO that I recently emailed out for
details on using SSH to forward NFS.  Only mountd and nfsd are
forwarded; lockd and statd are separate modules and would be difficult
to tunnel.  Therefore file locking won't work.  Your best bet to have
encrypted traffic in a production environment would probably be IPSec
(FreeSWAN).  You could also use Samba.  

Good luck,
Tavis
		

On Tue, 2002-03-19 at 10:12, Dumas Patrice wrote:
> Hi,
> I have a redhat 7.2 with nfs-utils 0.3.1, linux 2.4.7-10, mount-2.11g, portmap
> 4.0. The lockd is in the kernel. I use sec_rpc-1.13 to forward the rpc connections
> (http://www.math.ualberta.ca/imaging/snfs/)
> 
> I have a file /file_on_remote on the "remote" host, I want to mount it on the
> "local" host. I use the following /etc/fstab entry:
> 
> local:/file_on_remote /file_on_remote nfs rw,mountprog=201000,nfsprog=200003
> 
> I have a running rpc_psrv serveur which forwards the rpc requests with rpc
> numbers 201000 and 200003 to host "remote" ; service 201000 is forwarded as
> 100005 on "remote" and 200003 as 100003. after
> mount  /file_on_remote
> I can access the files which are on remote in /file_on_remote, but the locking
> mechanism doesn't work (I test it with mutt, as it reports that he couldn't
> make a lock, maybe there could be cleaner ways to test for it...).
> 
> Is it normal that the locking fails in this situation (nfs forwarded) ? What
> could I do to have it work ?
> 
> 
> This may be unrelated, or not : there is a strange thing which happen when I
> do, on "local":
> umount  /file_on_remote
> It responds:
> Cannot MOUNTPROG RPC: RPC: Programm not registered
> 
> The filesystem seems to be cleanly unmounted, however.
> 
> more info
> /etc/exports on "remote" (ip of remote is 193.51.xxx.yyy)
> 
> /file_on_remote 193.51.xxx.yyy(rw)
> 
> rpcinfo on "remote" gives
> [root@remote nfs-utils-0.3.1]# rpcinfo -p
>    program no_version protocole  no_port
>     100000    2   tcp    111  portmapper
>     100000    2   udp    111  portmapper
>     100011    1   udp    986  rquotad
>     100011    2   udp    986  rquotad
>     100011    1   tcp    989  rquotad
>     100011    2   tcp    989  rquotad
>     100005    1   udp  32769  mountd
>     100005    1   tcp  32769  mountd
>     100005    2   udp  32769  mountd
>     100005    2   tcp  32769  mountd
>     100005    3   udp  32769  mountd
>     100005    3   tcp  32769  mountd
>     100003    2   udp   2049  nfs
>     100003    3   udp   2049  nfs
>     100021    1   udp  32770  nlockmgr
>     100021    3   udp  32770  nlockmgr
>     100021    4   udp  32770  nlockmgr
>     100024    1   udp  35165  status
>     100024    1   tcp  46514  status
> 
> and on "local"
> [root@local nfs-utils-0.3.1]# rpcinfo -p
>    program no_version protocole  no_port
>     100000    2   tcp    111  portmapper
>     100000    2   udp    111  portmapper
>     100024    1   udp   1024  status
>     100024    1   tcp   1024  status
>     201000    3   udp   1036
>     200003    3   udp   1036
>     100021    1   udp   1037  nlockmgr
>     100021    3   udp   1037  nlockmgr
>     100021    4   udp   1037  nlockmgr
> 
> Pat
> 
> _______________________________________________
> NFS maillist  -  NFS@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/nfs
-- 
---------------------------------------------------------

Tavis Barr                          ,-~~-.___.        
Assistant Professor of Economics   / |  '     \             
Long Island University            (  )        0               
202 Hoxie Hall                     \_/-, ,----'            
C.W. Post Campus, 720 Northern Blvd.  ====           //
Brookville, NY  11548                 /  \-'~;    /~~~(O)
516-299-2321                         /  __/~|   /       |    
tavis.barr@liu.edu                 =(  _____| (_________|

---------------------------------------------------------

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
