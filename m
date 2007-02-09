From: "Kevin Coffman" <kwc@citi.umich.edu>
Subject: Re: NFSv3 + krb5 home directory problem
Date: Thu, 8 Feb 2007 21:53:45 -0500
Message-ID: <4d569c330702081853qca7178as27659b4e469f6e5@mail.gmail.com>
References: <20070208222606.23464.71348.stgit@rock.citi.umich.edu>
	<20070208222750.23464.34565.stgit@rock.citi.umich.edu>
	<45CBAAC2.1090105@CS.Arizona.EDU>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: "Jim Davis" <jdavis@cs.arizona.edu>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HFLtR-0002UE-2M
	for nfs@lists.sourceforge.net; Thu, 08 Feb 2007 18:53:45 -0800
Received: from ug-out-1314.google.com ([66.249.92.171])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HFLtS-0004Ko-PV
	for nfs@lists.sourceforge.net; Thu, 08 Feb 2007 18:53:47 -0800
Received: by ug-out-1314.google.com with SMTP id z38so662577ugc
	for <nfs@lists.sourceforge.net>; Thu, 08 Feb 2007 18:53:45 -0800 (PST)
In-Reply-To: <45CBAAC2.1090105@CS.Arizona.EDU>
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

On 2/8/07, Jim Davis <jdavis@cs.arizona.edu> wrote:
> I've been trying to get NFSv3 home directory mounts with sec=krb5
> working between a Netapp filer running OnTap 7.0.5 and a Fedora Core 6
> client with the latest nfs-* RPMs installed and kernel version
> 2.6.18-1.2869.fc6.  Our KDCs run FreeBSD 6.1 with the MIT Kerberos
> port installed.  Authentication seems to work okay,
>

> Running rpc.gssd in verbose mode produced
>
> Script started on Thu Feb  8 15:30:29 2007
> bsod$ /sbin/lsmod | grep sunrpc
> sunrpc                158333  6
> nfs,lockd,nfs_acl,rpcsec_gss_krb5,auth_rpcgss
> bsod$ mount | grep rpc_pipe
> sunrpc on /var/lib/nfs/rpc_pipefs type rpc_pipefs (rw)
> bsod$ sudo strace -o /tmp/rpc.gssd -f /usr/sbin/rpc.gssd -f -vvv
> Using keytab file '/etc/krb5.keytab'
> Processing keytab entry for principal
> 'nfs/bsod.cs.arizona.edu@CS.ARIZONA.EDU'
> We will use this entry (nfs/bsod.cs.arizona.edu@CS.ARIZONA.EDU)
> Using (machine) credentials cache:
> 'MEMORY:/tmp/krb5cc_machine_CS.ARIZONA.EDU'
>
> That's the extent of output while the commands above ran.

So there is never an upcall to request a context for testacct.  That
seems like a kernel issue.  Any chance you have a different kernel
still on that machine you could try?

-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier.
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
