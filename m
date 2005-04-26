From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [2.6 patch] fs/nfsd/: possible cleanups
Date: Tue, 26 Apr 2005 12:37:40 -0400
Message-ID: <20050426163740.GA26367@fieldses.org>
References: <20050423000755.GN4355@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: neilb@cse.unsw.edu.au, nfs@lists.sourceforge.net,
	linux-kernel@vger.kernel.org
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DQT4O-0003bB-CL
	for nfs@lists.sourceforge.net; Tue, 26 Apr 2005 09:37:56 -0700
Received: from dsl093-002-214.det1.dsl.speakeasy.net ([66.93.2.214] helo=pickle.fieldses.org)
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1DQT4M-0001o9-RI
	for nfs@lists.sourceforge.net; Tue, 26 Apr 2005 09:37:56 -0700
To: Adrian Bunk <bunk@stusta.de>
In-Reply-To: <20050423000755.GN4355@stusta.de>
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

On Sat, Apr 23, 2005 at 02:07:55AM +0200, Adrian Bunk wrote:
> This patch contains the following possible cleanups:
> - make needlessly global code static
> - remove the following unused global function:
>   - nfs4state.c: set_no_grace

Got it, thanks.--b.


-------------------------------------------------------
SF.Net email is sponsored by: Tell us your software development plans!
Take this survey and enter to win a one-year sub to SourceForge.net
Plus IDC's 2005 look-ahead and a copy of this survey
Click here to start!  http://www.idcswdc.com/cgi-bin/survey?id=105hix
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
