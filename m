From: Philippe =?ISO-8859-15?Q?Gramoull=E9?= <philippe.gramoulle@mmania.com>
Subject: Re: Problems with statd and lockd
Date: Sun, 6 Apr 2003 01:06:58 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20030406010658.6fb15983.philippe.gramoulle@mmania.com>
References: <20030405015638.5118fbb9.philippe.gramoulle@mmania.com>
	<200304051545.43063.bernd-schubert@web.de>
	<shs7ka9c957.fsf@charged.uio.no>
	<200304051831.09682.bernd-schubert@web.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from pgramoul.net2.nerim.net ([80.65.227.234] helo=philou.aspic.com)
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 191wko-0008Ip-00
	for <nfs@lists.sourceforge.net>; Sat, 05 Apr 2003 15:07:18 -0800
Received: from philou.gramoulle.local (philou.gramoulle.local [192.168.254.2])
	by philou.aspic.com (Postfix) with SMTP id 099C816EF
	for <nfs@lists.sourceforge.net>; Sun,  6 Apr 2003 01:06:59 +0200 (CEST)
To: nfs@lists.sourceforge.net
In-Reply-To: <200304051831.09682.bernd-schubert@web.de>
Errors-To: nfs-admin@lists.sourceforge.net
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>


Now i remember : i also built nfs-utils logn time ago and IIRC, i had disable
secure stad. It was old enough that since, so many things went through that i had forgotten that.

As this one is a standard debian package, it has secure statd enabled by default.

Running without secure statd would mean that lockd can be used by other than lockd, 
and also that hostnames resolve to dotted quads right ?

Thanks,

Philippe

On Sat, 5 Apr 2003 18:31:09 +0200
Bernd Schubert <bernd-schubert@web.de> wrote:

  | Recently the self-created nfs-utils packages 
  | (with disabled --enable-secure-statd) got replaced by an automatic update. 
  | Some time afterwards our clients began to give those messages (here as 
  | dmesg-output):
  | 
  | statd: server localhost not responding, timed out
  | nsm_mon_unmon: rpc failed, status=-5
  | lockd: cannot monitor <server IP>
  | lockd: failed to monitor <server IP>


-------------------------------------------------------
This SF.net email is sponsored by: ValueWeb: 
Dedicated Hosting for just $79/mo with 500 GB of bandwidth! 
No other company gives more support or power for your dedicated server
http://click.atdmt.com/AFF/go/sdnxxaff00300020aff/direct/01/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
