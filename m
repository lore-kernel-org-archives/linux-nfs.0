From: Scott Mcdermott <smcdermott@questra.com>
Subject: Re: Re: broken umount -f
Date: Tue, 14 Jan 2003 17:17:55 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20030114221755.GB1042@questra.com>
References: <6440EA1A6AA1D5118C6900902745938E07D551E8@black.eng.netapp.com> <20030114170755.GA18952@questra.com> <shs8yxn5z6m.fsf@charged.uio.no> <20030114191953.GJ26872@questra.com> <15908.26262.547106.640066@charged.uio.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from ns1.questra.com ([64.132.48.186])
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18YZNe-0003j9-00
	for <nfs@lists.sourceforge.net>; Tue, 14 Jan 2003 14:17:58 -0800
Received: from questra.com (hades.roc.questra.com [64.132.48.226])
	by ns1.questra.com (Postfix) with SMTP id 6F326AB77D
	for <nfs@lists.sourceforge.net>; Tue, 14 Jan 2003 17:17:55 -0500 (EST)
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <15908.26262.547106.640066@charged.uio.no>
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

Trond Myklebust on Tue 14/01 20:35 +0100:
>      > Last I checked, the programs wouldn't die even with -KILL when
>      > they were stuck in device-wait state.
> 
> They will if you mount with 'intr', and make sure that you kill *all*
> programs that are using that mountpoint.

I don't want users to be able to corrupt their own data by using `intr'
when I am just bouncing the server for some reason.  But, I want root to
be able to force it if necessary, as in the case of a client reboot when
the server is gone (eg when switching servers and they need new handles
for their automounts, but still have the old ones and the server is
never coming back up).  Usually this means the admin screwed up, but
unfortunately that does happen.

"umount -f" seems like the right place for this.


-------------------------------------------------------
This SF.NET email is sponsored by: Take your first step towards giving 
your online business a competitive advantage. Test-drive a Thawte SSL 
certificate - our easy online guide will show you how. Click here to get 
started: http://ads.sourceforge.net/cgi-bin/redirect.pl?thaw0027en
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
