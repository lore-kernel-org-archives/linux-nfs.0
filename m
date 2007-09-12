From: Le Rouzic <aime.le-rouzic@bull.net>
Subject: applications hangs with linux-2.6.23-rc5-CITI_NFS4_ALL-1.
Date: Wed, 12 Sep 2007 18:14:25 +0200
Message-ID: <46E81061.2070601@bull.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfsv4 <nfsv4@linux-nfs.org>, nfs@lists.sourceforge.net
Return-path: <nfsv4-bounces@linux-nfs.org>
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

Hi,
Running linux-2.6.23-rc5-CITI_NFS4_ALL-1.diff on two Intel x86_64 bi-ways,
all applications(iozone,fsstress,fsx,cthon,ffsb)  using the same repertory
mounted by NFSV4 stop systematically after 2-3 hours, the repertory being
no longer accessible even by the ls command.

See stacks and traces about the status of the applications at:
------------------------------------------------------------
Bug:
 http://bugzilla.linux-nfs.org/show_bug.cgi?id=146

Cheers

-- 
-----------------------------------------------------------------
Company : Bull, Architect of an Open World TM (www.bull.com)
Name    : Aime Le Rouzic 
Mail    : Bull - BP 208 - 38432 Echirolles Cedex - France
E-Mail  : aime.le-rouzic@bull.net
Phone   : 33 (4) 76.29.75.51
Fax     : 33 (4) 76.29.75.18
----------------------------------------------------------------- 
