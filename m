From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: gss/krb doesnt work with nfsv3?
Date: Wed, 2 Jun 2004 12:41:37 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20040602164136.GB4123@fieldses.org>
References: <Pine.LNX.4.58.0406021704290.3160@fogarty.jakma.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux NFS <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BVYoD-0007LX-73
	for nfs@lists.sourceforge.net; Wed, 02 Jun 2004 09:41:45 -0700
Received: from dsl093-002-214.det1.dsl.speakeasy.net
	([66.93.2.214] helo=pumpkin.fieldses.org ident=Debian-exim)
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:RC4-SHA:128)
	(Exim 4.30)
	id 1BVYoC-00035C-QR
	for nfs@lists.sourceforge.net; Wed, 02 Jun 2004 09:41:44 -0700
To: Paul Jakma <paul@clubi.ie>
In-Reply-To: <Pine.LNX.4.58.0406021704290.3160@fogarty.jakma.org>
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

On Wed, Jun 02, 2004 at 05:24:19PM +0100, Paul Jakma wrote:
> I can not get gss/krb exports to work with NFSv3:
> 
> # exportfs -v | grep test ; showmount -e | grep test
> /exports/test   gss/krb5(rw,wdelay,no_root_squash)
> # /etc/init.d/rpcgssd status
> rpc.gssd (pid 1556) is running...
> # /etc/init.d/rpcsvcgssd status
> rpc.svcgssd (pid 26833) is running...
> 
> If I try to mount from a client, I get the following:
> 
> # mount -o sec=krb5 hibernia:/exports/test /mnt/backup/
> mount: hibernia:/exports/test failed, reason given by server: 
> Permission denied
> 
> And in the server logs:
> 
> Jun  2 17:08:15 hibernia rpc.mountd: refused mount request from 
> fogarty.jakma.org for /exports/test (/): not exported
> 
> It works if i export with fsid=0 and mount with nfs4 sec=on the 
> client. Is krb5 supposed to work with NFSv3?

Yes, and it's working for me.  What version of nfs-utils is your mountd
from?  And could I take a look at a trace of the network traffic during
the failed mount?

--b.


-------------------------------------------------------
This SF.Net email is sponsored by the new InstallShield X.
