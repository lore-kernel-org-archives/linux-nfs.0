From: "David P. Quigley" <dpquigl@tycho.nsa.gov>
Subject: xlog and idmapd code cleanup and reuse
Date: Mon, 10 Sep 2007 17:25:43 -0400
Message-ID: <1189459543.7914.16.camel@moss-terrapins.epoch.ncsc.mil>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfs@lists.sourceforge.net, nfsv4@linux-nfs.org
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

nfs-utils originally had three different logging mechanisms used in the
code.This patch set makes the xlog implementation the one logging
mechanism for nfs-utils. It also reworks xlog to remove all the unsafe
behavior that already existed and updates all the appropriate callers.
Finally it removes unnecessary code from idmapd.

This series has been tested on my FC7 machine and produces the same
logging output as the unmodified verson. I haven't tested if the code
compiles on BSD or MacOSX but I haven't used anything that is Linux
specific.

Signed-off-by: David P. Quigley <dpquigl@tycho.nsa.gov>
