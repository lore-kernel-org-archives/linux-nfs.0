From: Open Source <opensource3141@yahoo.com>
Subject: Re: [NFS] "mount: File exists" when trying to mount a second krb5
	volume!
Date: Thu, 16 Nov 2006 23:45:30 +0800 (CST)
Message-ID: <20061116154530.82497.qmail@web58111.mail.re3.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, nfsv4@linux-nfs.org
Return-path: <nfsv4-bounces@linux-nfs.org>
To: Kostas Georgiou <k.georgiou@imperial.ac.uk>
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

Hi Kostas,

Understood.  But from what I know, usually people only
mount one pseudofilesystem from an nfsv4 server
onto their client.  I think that's why many people
haven't seen this problem with nfsv4+krb5!

Paarvai

----- Original Message ----
From: Kostas Georgiou <k.georgiou@imperial.ac.uk>
To: Open Source <opensource3141@yahoo.com>
Cc: nfsv4@linux-nfs.org; nfs@lists.sourceforge.net
Sent: Thursday, November 16, 2006 7:35:28 AM
Subject: Re: [NFS] "mount: File exists" when trying to mount a second krb5 volume!

On Wed, Nov 15, 2006 at 06:31:17PM -0800, Open Source wrote:

....

> This bug does not exist under 2.6.17 since client directories
> in /var/lib/nfs/rpc_pipefs/nfs are not reused across different
> nfsv3+krb5 mounts to the same server.

For the record I have the same problem with nfs4+krb5 in 2.6.18
so it's not just nfs3.

Kostas
