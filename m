From: Jeffrey Layton <jtlayton@poochiereds.net>
Subject: Re: Poor NFS performance, kernel 2.6.6.
Date: Wed, 02 Jun 2004 09:40:26 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1086183626.3370.6.camel@tesla.mmt.bellhowell.com>
References: <1086179633.3325.0.camel@tesla.mmt.bellhowell.com>
	 <20040602130054.GP323@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BVVyn-0005FE-V9
	for nfs@lists.sourceforge.net; Wed, 02 Jun 2004 06:40:29 -0700
Received: from rdu26-93-067.nc.rr.com ([66.26.93.67] helo=salusa.poochiereds.net)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.30)
	id 1BVVyn-0003Zf-Jt
	for nfs@lists.sourceforge.net; Wed, 02 Jun 2004 06:40:29 -0700
To: Greg Banks <gnb@sgi.com>
In-Reply-To: <20040602130054.GP323@sgi.com>
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

On Wed, 2004-06-02 at 09:00, Greg Banks wrote:
> On Wed, Jun 02, 2004 at 08:33:53AM -0400, Jeffrey Layton wrote:
> > The machines are different hardware, but local write performance is
> > pretty comparable (in fact the 2.6 box is a faster machine, and is
> > currently less utilized than the 2.4 kernel machine). Both are using
> > reiserfs as the underlying filesystem.
> 
> What is the speed on each server for a local dd from /dev/zero to disk?
> What actual kernel versions are you running?
> 

I need to amend my statement above. I'm having a problem mounting the
filesystem from the 2.6 kernel as v3. I keep getting a message saying
that v3 isn't supported, even though I can mount using v3 from the 2.4
box without an issue. Another 2.6 box doesn't seem to have this issue,
so I'm unsure of what the deal is. Rebuilding my client's kernel to see
if I can clear up that problem. Once I get that redone, I'll redo this
test and see if the poor performance remains...


In any case...

Less than .2 secs to do a local dd to disk:

laytonj@angstrom:/services/NFS/home% time dd if=/dev/zero of=./testfile
bs=100M count=1
1+0 records in
1+0 records out
104857600 bytes transferred in 0.200756 seconds (522313514 bytes/sec)
dd if=/dev/zero of=./testfile bs=100M count=1  0.00s user 0.20s system
107% cpu 0.186 total

It's a stock 2.6.6 kernel (the 'a' is an internal versioning scheme I
use when I have multiple kernel builds of same version):

laytonj@angstrom:/services/NFS/home% uname -a
Linux angstrom 2.6.6a #1 Mon May 17 14:29:24 EDT 2004 i686 GNU/Linux





-------------------------------------------------------
This SF.Net email is sponsored by the new InstallShield X.
