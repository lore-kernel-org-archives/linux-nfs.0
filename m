From: "G. Allen Morris III" <gam3-nfs@gam3.net>
Subject: Re: [RFC] nfsstat v4 layout
Date: Wed, 16 Mar 2005 17:33:27 -0500
Message-ID: <20050316223327.GA7137@gam3.net>
References: <20050316173759.GA4360@gam3.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DBh5G-0002zn-9n
	for nfs@lists.sourceforge.net; Wed, 16 Mar 2005 14:33:46 -0800
Received: from mta13.mail.adelphia.net ([68.168.78.44] helo=mta13.adelphia.net)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.41)
	id 1DBh5F-0004gC-NU
	for nfs@lists.sourceforge.net; Wed, 16 Mar 2005 14:33:46 -0800
Received: from harpo.ny.gam3.net ([68.235.28.141]) by mta13.adelphia.net
          (InterMail vM.6.01.04.01 201-2131-118-101-20041129) with ESMTP
          id <20050316223332.FBDI4618.mta13.adelphia.net@harpo.ny.gam3.net>
          for <nfs@lists.sourceforge.net>; Wed, 16 Mar 2005 17:33:32 -0500
Received: from gam3 by harpo.ny.gam3.net with local (Exim 3.36 #1 (Debian))
	id 1DBh4x-0001u8-00
	for <nfs@lists.sourceforge.net>; Wed, 16 Mar 2005 17:33:27 -0500
To: nfs@lists.sourceforge.net
In-Reply-To: <20050316173759.GA4360@gam3.net>
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

On Wed, Mar 16, 2005 at 12:37:59PM -0500, G. Allen Morris III wrote:
> 
> I made a patch to nfsstat to display v4 stats.
> I am having a problem with some of the names being so
> long setclientid_confirm for instance.  
> 
> Is the format below too confusing?  Anyone have a better idea?
> 

I increased the count to `-8d' and the rows are now 76 charaters
wide.  To make them wider I would think about reducing to 5 columns
or making it dynamic (like ls).

I also changed the v4 names to abbreviations.

Allen

--
Server packet stats:
packets    udp        tcp        tcpconn
0          3727       0          0       

Server rpc stats:
calls      badcalls   badauth    badclnt    xdrcall
3730       0          0          0          0       

Server reply cache:
hits       misses     nocache
0          0          3730    

Server file handle cache:
lookup     anon       ncachedir ncachedir  stale
0          0          0          0          1242    
Server nfs v2:
null         getattr      setattr      root         lookup       readlink     
0         0% 0         0% 0         0% 0         0% 0         0% 0         0% 
read         wrcache      write        create       remove       rename       
0         0% 0         0% 0         0% 0         0% 0         0% 0         0% 
link         symlink      mkdir        rmdir        readdir      fsstat       
0         0% 0         0% 0         0% 0         0% 0         0% 0         0% 

Server nfs v3:
null         getattr      setattr      lookup       access       readlink     
1         0% 0         0% 0         0% 0         0% 0         0% 0         0% 
read         write        create       mkdir        symlink      mknod        
0         0% 0         0% 0         0% 0         0% 0         0% 0         0% 
remove       rmdir        rename       link         readdir      readdirplus  
0         0% 0         0% 0         0% 0         0% 0         0% 0         0% 
fsstat       fsinfo       pathconf     commit       
3729     99% 0         0% 0         0% 0         0% 

Server nfs v4:
null         compound     
0         0% 0         0% 

Client packet stats:
packets    udp        tcp        tcpconn
0          0          0          0       

Client rpc stats:
calls      retrans    authrefrsh
2          0          0       

Client nfs v2:
null         getattr      setattr      root         lookup       readlink     
0         0% 0         0% 0         0% 0         0% 0         0% 0         0% 
read         wrcache      write        create       remove       rename       
0         0% 0         0% 0         0% 0         0% 0         0% 0         0% 
link         symlink      mkdir        rmdir        readdir      fsstat       
0         0% 0         0% 0         0% 0         0% 0         0% 0         0% 

Client nfs v3:
null         getattr      setattr      lookup       access       readlink     
0         0% 1        50% 0         0% 0         0% 0         0% 0         0% 
read         write        create       mkdir        symlink      mknod        
0         0% 0         0% 0         0% 0         0% 0         0% 0         0% 
remove       rmdir        rename       link         readdir      readdirplus  
0         0% 0         0% 0         0% 0         0% 0         0% 0         0% 
fsstat       fsinfo       pathconf     commit       
0         0% 1        50% 0         0% 0         0% 

Client nfs v4:
null         read         write        commit       open         open_conf    
0         0% 0         0% 0         0% 0         0% 0         0% 0         0% 
open_noat    open_dgrd    close        setattr      fsinfo       renew        
0         0% 0         0% 0         0% 0         0% 0         0% 0         0% 
setclntid    confirm      lock         lockt        locku        access       
0         0% 0         0% 0         0% 0         0% 0         0% 0         0% 
getattr      lookup       lookup_root  remove       rename       link         
0         0% 0         0% 0         0% 0         0% 0         0% 0         0% 
symlink      create       pathconf     statfs       readlink     readdir      
0         0% 0         0% 0         0% 0         0% 0         0% 0         0% 
server_caps  delegreturn  
0         0% 0         0% 



-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
