From: Frank Steiner <frank.steiner@ifi.lmu.de>
Subject: Re: Hanging udev process on nfs-mounted /dev
Date: Tue, 28 Sep 2004 11:15:29 +0200
Sender: linux-usb-users-admin@lists.sourceforge.net
Message-ID: <41592BB1.9030107@ifi.lmu.de>
References: <41592550.5060006@bio.ifi.lmu.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Cc: NFS NFS <nfs@lists.sourceforge.net>,
	USB users list <linux-usb-users@lists.sourceforge.net>
Return-path: <linux-usb-users-admin@lists.sourceforge.net>
To: Frank Steiner <fsteiner-mail@bio.ifi.lmu.de>
In-Reply-To: <41592550.5060006@bio.ifi.lmu.de>
Errors-To: linux-usb-users-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/linux-usb-users>,
	<mailto:linux-usb-users-request@lists.sourceforge.net?subject=unsubscribe>
List-Post: <mailto:linux-usb-users@lists.sourceforge.net>
List-Help: <mailto:linux-usb-users-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/linux-usb-users>,
	<mailto:linux-usb-users-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=linux-usb-users>
List-ID: <nfs.lists.sourceforge.net>

Sorry, a small mistake I made: The udevstart.* script are not the
strace output from /sbin/udevstart, but seem to be initiated from
SuSEs /etc/init.d/boot.device-mapper script, which e.g. fscks the
filesystems etc.
Just that you don't wonder why the logs look so much different
from a udevstart output :-)

-- 
Dipl.-Inform. Frank Steiner   Web:  http://www.bio.ifi.lmu.de/~steiner/
Lehrstuhl f. Bioinformatik    Mail: http://www.bio.ifi.lmu.de/~steiner/m/
LMU, Amalienstr. 17           Phone: +49 89 2180-4049
80333 Muenchen, Germany       Fax:   +49 89 2180-99-4049
* Rekursion kann man erst verstehen, wenn man Rekursion verstanden hat. *


-------------------------------------------------------
This SF.Net email is sponsored by: YOU BE THE JUDGE. Be one of 170
Project Admins to receive an Apple iPod Mini FREE for your judgement on
who ports your project to Linux PPC the best. Sponsored by IBM.
Deadline: Sept. 24. Go here: http://sf.net/ppc_contest.php
_______________________________________________
Linux-usb-users@lists.sourceforge.net
To unsubscribe, use the last form field at:
https://lists.sourceforge.net/lists/listinfo/linux-usb-users
