From: Greg Banks <gnb@sgi.com>
Subject: Re: Poor NFS performance, kernel 2.6.6.
Date: Wed, 2 Jun 2004 23:00:54 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20040602130054.GP323@sgi.com>
References: <1086179633.3325.0.camel@tesla.mmt.bellhowell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BVVMf-0005PR-0N
	for nfs@lists.sourceforge.net; Wed, 02 Jun 2004 06:01:05 -0700
Received: from mtvcafw.sgi.com ([192.48.171.6] helo=omx2.sgi.com)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.30)
	id 1BVVMe-00035K-Gi
	for nfs@lists.sourceforge.net; Wed, 02 Jun 2004 06:01:04 -0700
To: Jeffrey Layton <jtlayton@poochiereds.net>
In-Reply-To: <1086179633.3325.0.camel@tesla.mmt.bellhowell.com>
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

On Wed, Jun 02, 2004 at 08:33:53AM -0400, Jeffrey Layton wrote:
> The machines are different hardware, but local write performance is
> pretty comparable (in fact the 2.6 box is a faster machine, and is
> currently less utilized than the 2.4 kernel machine). Both are using
> reiserfs as the underlying filesystem.

What is the speed on each server for a local dd from /dev/zero to disk?
What actual kernel versions are you running?

> Write performance in this cursory test was 10x worse!

This completely fails to correlate with my experience.  I'm using XFS
on 2.6.4 and I see single thread streaming write performance increase
by about 25% going from 2.4 to 2.6.  Other metrics show improvements
as good or better, except the scalability of UDP reads tops out lower.

Greg.
-- 
Greg Banks, R&D Software Engineer, SGI Australian Software Group.
I don't speak for SGI.


-------------------------------------------------------
This SF.Net email is sponsored by the new InstallShield X.
