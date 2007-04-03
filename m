From: Phillip <phuang@plasmon.cn>
Subject: Re: can not start NFSv4 with Kerberos 5
Date: Tue, 03 Apr 2007 20:13:27 +0800
Message-ID: <1175602407.4063.51.camel@localhost.localdomain>
References: <1175595021.3798.19.camel@localhost.localdomain>
	<89c397150704030446id0db9b1h30e20cfba0f5182a@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: "William A. (Andy) Adamson" <andros@citi.umich.edu>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HYhtr-0005Gx-I6
	for nfs@lists.sourceforge.net; Tue, 03 Apr 2007 05:14:11 -0700
Received: from [211.97.48.10] (helo=zh.plasmon.cn)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HYhtr-0001Ak-3w
	for nfs@lists.sourceforge.net; Tue, 03 Apr 2007 05:14:14 -0700
In-Reply-To: <89c397150704030446id0db9b1h30e20cfba0f5182a@mail.gmail.com>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

Andy,

Thanks for you kindly reply.

As your comment:
nfs/<your.host>@<YOUR.REALM>
and I google the following:
host/hostname@NT-DNS-REALM-NAME

hostname is the host DNS name, for example, foobar.microsoft.com.
NT-DNS-REALM-NAME is the uppercase name of the Windows 2000 domain; for
example, RESKIT.COM.

I have two questions:
1. What does the above term "host" mean? Hostname of NFS server, or
service(nfs)?
2. If I set the IP address in the above "<your.host>" field, is it OK?
How could I set the DNS name since I could not operate on the DNS
server?

Call me a piggy, but this is just where I am: I'm here for real.

Regards,
Phillip



On Tue, 2007-04-03 at 07:46 -0400, William A. (Andy) Adamson wrote:
> 
> 
> On 4/3/07, Phillip <phuang@plasmon.cn> wrote:
>         Hi folks,
>         
>         Currently we plan to use NFSV4 with Kerberos:
>         KDC: Windows 2K AD
>         
>         NFSv4 server: CentOS 4.4 with 2.6.20 kernel
>         # cat /etc/exports
>         /XFS/NFS4       gss/krb5
>         (rw,fsid=0,insecure,no_root_squash,no_subtree_check,sync) 
>         
>         Client: CentOS 4.4
>         
>         When I use Ktpass to create keytab:
>         
>         C:> Ktpass princ administrator/PLASMON.SIT@PLASMON.SIT mapuser
>         administrator -pass admin out unixmachine.keytab
>         C:> Ktpass princ root/PLAMONS.SIT@PLASMON.SIT mapuser root -
>         pass admin
>         out unixmachine_1.keytab
>         
>         
>         and copy this output keytabs to NFSv4 server, and then export
>         them with 
>         kinit well.
>         
>         However, when I attempt to start NFS service, the rpcsvcgssd
>         failed.
>         
>         Then I try to execute these below commands
>         
>         [root@nfsv4 kevin]# rpc.svcgssd -fvvv
>         ERROR: GSS-API: error in gss_import_name(): An invalid name
>         was supplied 
>         - Hostname cannot be canonicalized
>         unable to obtain root (machine) credentials
>         do you have a keytab entry for nfs/<your.host>@<YOUR.REALM>
>         in /etc/krb5.keytab?
> 
> as the error message on the server said: you need a keytab of the
> form 
> 
> nfs/<your.host>@<YOUR.REALM>
> 
> the root/<your.host>@<YOUR.REALM> or
> administrator/<your.host>@<YOUR.REALM> won/t work.
> 
> -->Andy
> 
> 
>         [root@nfsv4 kevin]# rpc.gssd -fvvv
>         Using keytab file '/etc/krb5.keytab'
>         Processing keytab entry for principal
>         'administrator/PLASMON.SIT@PLASMON.SIT'
>         We will NOT use this entry
>         (administrator/PLASMON.SIT@PLASMON.SIT)
>         Processing keytab entry for principal
>         'root/PLASMON.SIT@PLASMON.SIT'
>         We will NOT use this entry (root/PLASMON.SIT@PLASMON.SIT)
>         ERROR: No usable keytab entries found in keytab
>         '/etc/krb5.keytab' 
>         Do you have a valid keytab entry for
>         nfs/<your.host>@<YOUR.REALM> in
>         keytab file /etc/krb5.keytab ?
>         Continuing without (machine) credentials - nfs4 mounts with
>         Kerberos
>         will fail
>         processing client list 
>         
>         
>         Did I take mistakes in creating keytab?
>         
>         
>         Please help me fix this issue.
>         Thanks in advance.
>         
>         Regards,
>         Phillip
>         
>         
>         
>         
>         ------------------------------------------------------------------------- 
>         Take Surveys. Earn Cash. Influence the Future of IT
>         Join SourceForge.net's Techsay panel and you'll get the chance
>         to share your
>         opinions on IT & business topics through brief surveys-and
>         earn cash
>         http://www.techsay.com/default.php?
>         page=join.php&p=sourceforge&CID=DEVDEV
>         _______________________________________________ 
>         NFS maillist  -  NFS@lists.sourceforge.net
>         https://lists.sourceforge.net/lists/listinfo/nfs
>         
> 


-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
