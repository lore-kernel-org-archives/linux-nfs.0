From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Re: broken umount -f
Date: Tue, 14 Jan 2003 20:35:50 +0100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <15908.26262.547106.640066@charged.uio.no>
References: <6440EA1A6AA1D5118C6900902745938E07D551E8@black.eng.netapp.com>
	<20030114170755.GA18952@questra.com>
	<shs8yxn5z6m.fsf@charged.uio.no>
	<20030114191953.GJ26872@questra.com>
Reply-To: trond.myklebust@fys.uio.no
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from mons.uio.no ([129.240.130.14] ident=7411)
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18YWqq-0003zl-00
	for <nfs@lists.sourceforge.net>; Tue, 14 Jan 2003 11:35:56 -0800
To: Scott Mcdermott <smcdermott@questra.com>
In-Reply-To: <20030114191953.GJ26872@questra.com>
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

>>>>> " " == Scott Mcdermott <smcdermott@questra.com> writes:

     > Last I checked, the programs wouldn't die even with -KILL when
     > they were stuck in device-wait state.

They will if you mount with 'intr', and make sure that you kill *all*
programs that are using that mountpoint.

If somebody wants to work on 'umount -f' then by all means do...

Cheers,
  Trond


-------------------------------------------------------
This SF.NET email is sponsored by: Take your first step towards giving 
your online business a competitive advantage. Test-drive a Thawte SSL 
certificate - our easy online guide will show you how. Click here to get 
started: http://ads.sourceforge.net/cgi-bin/redirect.pl?thaw0027en
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
