From: Olaf Kirch <okir@suse.de>
Subject: Re: about group membership
Date: Tue, 11 May 2004 20:22:00 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20040511182200.GA17246@suse.de>
References: <40A10989.80300@yahoo.com.cn>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: NFS-devel <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BNbtE-0004Dr-2h
	for nfs@lists.sourceforge.net; Tue, 11 May 2004 11:22:04 -0700
Received: from ns.suse.de ([195.135.220.2] helo=Cantor.suse.de)
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.30)
	id 1BNbtD-0005rQ-Gv
	for nfs@lists.sourceforge.net; Tue, 11 May 2004 11:22:03 -0700
To: MeiJia <cfs_eric@yahoo.com.cn>
In-Reply-To: <40A10989.80300@yahoo.com.cn>
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

On Tue, May 11, 2004 at 11:12:41AM -0600, MeiJia wrote:
> While i'm looking at the NFS (include v4), I didn't find any code which 
> handle supplement group membership issues. so I'm curious how could NFS 
> deal with following situations, or what's the plan to support:
>  - normal supplement groups

Supplementary groups are transported in the AUTH_UNIX credentials.
If you you use a different authentication flavor, supplementary
groups are usually retrieved from the password database.

>  - setuid binaries

Linux nfs normally uses the effective uid in any requests
(if credentials are available; which is not a given for all
auth flavors).

There is an option to fall back to the real uid in certain cases,
but that is really more of a hack.

>  - setgroups binaries

I think we just add the effective uid to the groups vector,
if it is different from the rgid.

Olaf

-- 
Olaf Kirch     |  The Hardware Gods hate me.
okir@suse.de   |
---------------+ 


-------------------------------------------------------
This SF.Net email is sponsored by Sleepycat Software
Learn developer strategies Cisco, Motorola, Ericsson & Lucent use to deliver
higher performing products faster, at low TCO.
http://www.sleepycat.com/telcomwpreg.php?From=osdnemail3
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
