From: Frank Steiner <fsteiner-mail@bio.ifi.lmu.de>
Subject: Re: ps -aux hangs on [nfsd]
Date: Fri, 28 Jan 2005 14:47:47 +0100
Message-ID: <41FA4283.6080606@bio.ifi.lmu.de>
References: <41DE6CF9.6030100@bio.ifi.lmu.de> <41F8C900.90404@bio.ifi.lmu.de> <20050128102223.GB32084@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: Frank Steiner <fsteiner-mail@bio.ifi.lmu.de>,
	NFS NFS <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CuWU2-0007cL-Uj
	for nfs@lists.sourceforge.net; Fri, 28 Jan 2005 05:48:22 -0800
Received: from acheron.informatik.uni-muenchen.de ([129.187.214.135])
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.41)
	id 1CuWTY-0002Mf-SR
	for nfs@lists.sourceforge.net; Fri, 28 Jan 2005 05:48:22 -0800
To: Olaf Kirch <okir@suse.de>
In-Reply-To: <20050128102223.GB32084@suse.de>
Sender: nfs-admin@lists.sourceforge.net
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

Olaf Kirch wrote

> This doesn't look like an NFS bug; it's a problem in procps or glibc.
> 
> When you do a ps aux, ps ends up in a function named simple_readtask
> (in procps/proc/readproc.c) which does this:
> 
> 	stat /proc/<pid>
> 	read /proc/<pid>/stat
> 	read /proc/<pid>/status
> 	map the uids it found to login names
 >
> The latter happens via a function named user_from_uid(), which caches
> these mappings - this is the reason why you're not seeing an access to
> /etc/passwd on every call.

Hmm, maybe that goes wrong, because the uid found in the status file
does not exist on the server. The server has only system users, but
exports the fs to a clients where real users exist. I checked the
content of /proc/15600/status which I recorder when it was hanging
and it shows

Name:   nfsd
State:  S (sleeping)
SleepAVG:       102%
Tgid:   15600
Pid:    15600
PPid:   1
TracerPid:      0
Uid:    0       0       0       19021
Gid:    0       0       0       19000
FDSize: 32
Groups: 14 16 17 33 19000
Threads:        1
SigPnd: 0000000000000000
ShdPnd: 0000000000000000
SigBlk: fffffffffffffef8
SigIgn: 0000000000000000
SigCgt: 0000000000000000
CapInh: 0000000000000000
CapPrm: 00000000ffffffff
CapEff: 00000000fefffee0

However, uid and gid 19021 and 19000 don't exist on the nfs server, only
on the clients mounting. Of course this shouldn't be a problem, but maybe
the bug is triggered by this situation?

Btw, I saw that the read command in tge strace log for /proc/15600/status
is the only one that ends with "= 373" while all reads for the other
nfsd processes end with "= 348". Could that indicate sth. is wrong
with this status file?

> But it doesn't look like user_from_uid() could loop at all. So
> possibly somethings wrong inside glibc (unlikely as that is).

All very puzzling and I've no idea how to track this down... Anyway
thanks for the explanation so far!

cu,
Frank



-- 
Dipl.-Inform. Frank Steiner   Web:  http://www.bio.ifi.lmu.de/~steiner/
Lehrstuhl f. Bioinformatik    Mail: http://www.bio.ifi.lmu.de/~steiner/m/
LMU, Amalienstr. 17           Phone: +49 89 2180-4049
80333 Muenchen, Germany       Fax:   +49 89 2180-99-4049
* Rekursion kann man erst verstehen, wenn man Rekursion verstanden hat. *


-------------------------------------------------------
This SF.Net email is sponsored by: IntelliVIEW -- Interactive Reporting
Tool for open source databases. Create drag-&-drop reports. Save time
by over 75%! Publish reports on the web. Export to DOC, XLS, RTF, etc.
Download a FREE copy at http://www.intelliview.com/go/osdn_nl
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
