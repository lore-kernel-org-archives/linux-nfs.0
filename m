From: Steve Dickson <SteveD@redhat.com>
Subject: Re: NFSv3 + Kerberos + x86_64 (Fedora Core 4)
Date: Wed, 01 Mar 2006 11:52:41 -0500
Message-ID: <4405D159.3070008@RedHat.com>
References: <200603010757.18563.gopal@nerur.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1FEUa7-0004XD-BS
	for nfs@lists.sourceforge.net; Wed, 01 Mar 2006 08:53:43 -0800
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1FEUa6-0006tR-6a
	for nfs@lists.sourceforge.net; Wed, 01 Mar 2006 08:53:43 -0800
To: Gopal Santhanam <gopal@nerur.com>
In-Reply-To: <200603010757.18563.gopal@nerur.com>
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



Gopal Santhanam wrote:
> Hi all,
> 
> I have been using FC4's kernel-2.6.15-1.1831 on both
> i686 and x86_64 architecture machines.
> 
> I want to use NFSv3 with Kerberos.  This works fine
> on i686 with the aforementioned FC4 kernel.  I am
> able to do the following:
> 
> 1) Setup NFS server with kerberos
> 
> 2) Mount on NFS client with -o sec=krb5.
> 
> 
> Now, if I have (1) on i686 and do (2) on x86_64, things just 
> break:
> 
> {root@x86_64client:3:~} mount -o sec=krb5 
> server:/export/test /mnt
> {root@x86_64client:4:~} ls -al /mnt
> ls: /mnt: Broken pipe
> 
> 
> 
> The clients are setup exactly the same
> (both have /etc/krb5.keytab, /etc/idmapd.conf). 
> They are both running rpc.idmapd and rpc.gssd.
> 
> An important thing to mention is that rpc.gssd is still running
> after the mount command but then has vanished (crashed?) after 
> the ls.
Try changing the library in /etc/gssapi_mech.conf from
/usr/lib/libgssapi_krb5.so to simply libgssapi_krb5.so.2

steved.


-------------------------------------------------------
This SF.Net email is sponsored by xPML, a groundbreaking scripting language
that extends applications into web and mobile media. Attend the live webcast
and join the prime developer group breaking into this new coding territory!
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=110944&bid=241720&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
