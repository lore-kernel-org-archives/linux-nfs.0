From: Chuck Lever <chuck.lever@Oracle.Com>
Subject: Re: [NFS] mount.nfs4 clientaddr= option inconsistent behaviour
Date: Mon, 06 Aug 2007 11:13:53 -0400
Message-ID: <46B73AB1.9080700@oracle.com>
References: <46B49C5D.7070803@oxeva.fr>
Reply-To: chuck.lever@Oracle.Com
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="------------030903070603080702070301"
Cc: nfs@lists.sourceforge.net, nfsv4@linux-nfs.org
To: Gabriel Barazer <gabriel@oxeva.fr>
Return-path: <nfsv4-bounces@linux-nfs.org>
In-Reply-To: <46B49C5D.7070803@oxeva.fr>
List-Unsubscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=unsubscribe>
List-Archive: <http://linux-nfs.org/pipermail/nfsv4>
List-Post: <mailto:nfsv4@linux-nfs.org>
List-Help: <mailto:nfsv4-request@linux-nfs.org?subject=help>
List-Subscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=subscribe>
Sender: nfsv4-bounces@linux-nfs.org
Errors-To: nfsv4-bounces@linux-nfs.org
List-ID: <nfs.lists.sourceforge.net>

This is a multi-part message in MIME format.
--------------030903070603080702070301
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

Hi Gabriel-

Gabriel Barazer wrote:
> There is an inconsistent behaviour of mount.nfs4 regarding how to 
> detect/handle the client IP address.
> The "clientaddr" option is allowed for mount.nfs4, but this address is 
> not used for the client IP address, and if there is any DNS failure or 
> misconfiguration, mount.nfs4 will fail.
> 
> The error is in get_my_ipv4addr() at nfs4mount.c:170 (nfs-utils-1.1.0). 
> This function fills *ip_addr with the client address, detected from the 
> resolved machine name (gethostname() which is tried to be resolved in 
> fill_ipv4_sockaddr). This cannot work if the machine name is not (yet) 
> properly resolvable in DNS at mount time (e.g. we are nfs4-mounting the 
> root filesystem very early). Using the clientaddr option provided before 
> trying to resolve the gethostname() hostname, would be IMHO a more 
> consistent behaviour.

I may be mistaken, but I don't think that the Linux NFSv4 implementation 
is made for mounting the root file system.  You may be wandering into an 
area that has had no testing, and in fact, the implementation may not be 
designed to do this at all.

> This can cause much trouble too with multihomed clients. The right way 
> would be to detect the client IP from the server IP (or resolved IP) 
> (and deal with clients with multiple addresses per subnet, by taking the 
> lowest address only)

Yes, this is good analysis, I think.  Neil Brown added some logic to 
mount recently that determines the client's IP address by opening a 
socket to the server, and capturing the local endpoint's address.  This 
takes into account which network interface is used on the client to 
contact the server.  I'm not sure whether this logic is used for 
determining the clientaddr address yet.

--------------030903070603080702070301
Content-Type: text/x-vcard; charset=utf-8;
 name="chuck.lever.vcf"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="chuck.lever.vcf"

begin:vcard
fn:Chuck Lever
n:Lever;Chuck
org:Oracle Corporation;Corporate Architecture: Linux Projects Group
adr:;;1015 Granger Avenue;Ann Arbor;MI;48104;USA
title:Principal Member of Staff
tel;work:+1 248 614 5091
x-mozilla-html:FALSE
url:http://oss.oracle.com/~cel
version:2.1
end:vcard


--------------030903070603080702070301
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFSv4 mailing list
NFSv4@linux-nfs.org
http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4
--------------030903070603080702070301--
