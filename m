From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH] NFS: implement option checking when remounting NFS
	filesystems
Date: Fri, 11 Apr 2008 15:01:33 -0400
Message-ID: <47FFB58D.6080902@oracle.com>
References: <1207937413-16189-1-git-send-email-jlayton@redhat.com>
Reply-To: chuck.lever@oracle.com
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="------------080701090305090207000800"
Cc: linux-nfs@vger.kernel.org, nfsv4@linux-nfs.org
To: Jeff Layton <jlayton@redhat.com>
Return-path: <nfsv4-bounces@linux-nfs.org>
In-Reply-To: <1207937413-16189-1-git-send-email-jlayton@redhat.com>
List-Unsubscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=unsubscribe>
List-Archive: <http://linux-nfs.org/pipermail/nfsv4>
List-Post: <mailto:nfsv4@linux-nfs.org>
List-Help: <mailto:nfsv4-request@linux-nfs.org?subject=help>
List-Subscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=subscribe>
Sender: nfsv4-bounces@linux-nfs.org
Errors-To: nfsv4-bounces@linux-nfs.org
List-ID: <linux-nfs.vger.kernel.org>

This is a multi-part message in MIME format.
--------------080701090305090207000800
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

Jeff Layton wrote:
> When remounting an NFS or NFS4 filesystem, the new NFS options are not
> respected, yet the remount will still return success. This patch adds
> a remount_fs sb op for NFS that checks any new nfs mount options against
> the existing ones and fails the mount if any have changed.
> 
> This is only implemented for string-based mount options since doing
> this with binary options isn't really feasible.

It might be feasible if mount.nfs were smart enough to read /etc/mtab 
and merge the old mount options with the remount options.

--------------080701090305090207000800
Content-Type: text/x-vcard; charset=utf-8;
 name="chuck_lever.vcf"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="chuck_lever.vcf"

begin:vcard
fn:Chuck Lever
n:Lever;Chuck
org:Oracle Corporation;Corporate Architecture: Linux Projects Group
adr:;;1015 Granger Avenue;Ann Arbor;MI;48104;USA
title:Principal Member of Staff
tel;work:+1 248 614 5091
x-mozilla-html:FALSE
version:2.1
end:vcard


--------------080701090305090207000800
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFSv4 mailing list
NFSv4@linux-nfs.org
http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4
--------------080701090305090207000800--
