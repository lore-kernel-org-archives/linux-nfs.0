From: Peter Staubach <staubach@redhat.com>
Subject: Re: 'noacl' NFS parameter seems ineffective (Fedora Core 7)
Date: Thu, 05 Jul 2007 17:19:32 -0400
Message-ID: <468D6064.3080307@redhat.com>
References: <a90f74cc0707051401p38167340s955be299a807710d@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: Myles Uyema <mlists@uyema.net>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1I6Yjh-00008v-1x
	for nfs@lists.sourceforge.net; Thu, 05 Jul 2007 14:19:37 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1I6Yjk-0007HJ-CS
	for nfs@lists.sourceforge.net; Thu, 05 Jul 2007 14:19:40 -0700
In-Reply-To: <a90f74cc0707051401p38167340s955be299a807710d@mail.gmail.com>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

Myles Uyema wrote:
> If I understand the explanation of the 'noacl' parameter, it should 
> prevent ACCESS calls right?  I'm not seeing this occurring on Fedora 
> Core 7 (2.6.21-1.3228.fc7 #1 SMP Tue Jun 12 14:56:37 EDT 2007 x86_64 
> x86_64 x86_64 GNU/Linux)
>
> I mounted using tcp,noacl,rsize=32768,wsize=32768.  The NFS server is 
> a NetApp filer running 7.2.1.1 <http://7.2.1.1>, and is a unix-only 
> filesystem.
>
> Then I ran a script to 'dd' 286 files on the NFS mountpoint.  The 
> script ran as UID 48.
> 340 reads
> 286 getattr
> 286 access
>
> The nfsstat showed my client still performing ACCESS calls.  I'd like 
> to believe that the GETATTR has already verified the permission bits, 
> and thus an ACCESS shouldn't be necessary. 

Actually, all that the "noacl" mount option means is to not attempt
to get or set or ACLs on the server.  It does not affect the security
checking that the client does to verify access.

The permission bits are not enough to determine access permissions.
Root mapping on the server is an easy example of this.  Therefore,
the client always goes over the wire to query the server for the
permissions that it will allow.

    Thanx...

       ps

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
