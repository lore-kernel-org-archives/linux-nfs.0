From: mehta kiran <kiranmehta1981@yahoo.com>
Subject: Re: Primary NFS doubts.           plz..................help
Date: Thu, 6 Jan 2005 06:09:10 -0800 (PST)
Message-ID: <20050106140910.38653.qmail@web51601.mail.yahoo.com>
References: <20050106103406.15539.qmail@webmail8.rediffmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CmYKG-0000Wy-0L
	for nfs@lists.sourceforge.net; Thu, 06 Jan 2005 06:09:20 -0800
Received: from web51601.mail.yahoo.com ([206.190.38.206])
	by sc8-sf-mx1.sourceforge.net with smtp (Exim 4.41)
	id 1CmYKD-0001O2-R0
	for nfs@lists.sourceforge.net; Thu, 06 Jan 2005 06:09:19 -0800
To: nac kawathekar <nascomp19@rediffmail.com>,
	nfs@lists.sourceforge.net
In-Reply-To: <20050106103406.15539.qmail@webmail8.rediffmail.com>
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

1. Only those clients to whom nfs server exports 
   filesystem can access it.while exporting , 
   server specifies uid , gid of user who
   can access filesystem.while mounting nfs
   server does all the validation to see if
   client can mount the filesystem.
   After mouting  ,client gets handle from 
   server (handle composed of fsid , root inode
   of mounted filesystem , etc)
   Later on client does all operations using
   this handle and server validates client
   using this handle. 
   See Man pages of nfs , exportfs , statd etc.

2. NIS is not compulsory for NFS. NIS(NIS server)
   is application which maintains database
  (passwd , /etc/hosts ,....) which
   can be used by all mahines(NIS client)
   Update this files on NIS server and they will
   avaiable to all  other NIS slave servers.
   NIS client can then send their query to
   these servers.Network login is verified using
   NIS.Eg: if u want to login to a machine 
   (with NIS client on it) nis client on that 
   machine will authenticate ur user name and 
   password by contacting NIS server.
   Ref book: NFS and NIS

3. There are NFS clients on windows also though
   not much popular.U can use those to mount
   nfs exported filesystem.More popular on 
   windows is  samba    
4. Explanation of different NFS daemons is available
   but i doubt if code explanation is available
   Best way to understand NFS is its source code.

-kiran
--- nac kawathekar <nascomp19@rediffmail.com> wrote:

>   
> Hello,
> 
> How NFS authenticates the client ? What information
> needs to be send by the client for authentication ?
> Is it uid,gid or what ?
> 
> To use NFS is it necessary to use NIS ? Is NIS a
> compulsory thing to use NFS? If not what is done ?
> 
> Can any windows client mount  NFS share ?
> 
> Can i get any explaination of NFS code on net and
> control flow of how NFS works exactly in detail.
> 
>  
> 



		
__________________________________ 
Do you Yahoo!? 
Take Yahoo! Mail with you! Get it on your mobile phone. 
http://mobile.yahoo.com/maildemo 


-------------------------------------------------------
The SF.Net email is sponsored by: Beat the post-holiday blues
Get a FREE limited edition SourceForge.net t-shirt from ThinkGeek.
It's fun and FREE -- well, almost....http://www.thinkgeek.com/sfshirt
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
