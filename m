From: =?koi8-r?Q?=22?=Peter Lojkin=?koi8-r?Q?=22=20?=<ia6432@inbox.ru>
Subject: Re: off_t in nfsd_commit needs to be loff_t
Date: Fri, 06 Feb 2004 06:20:13 +0300
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <E1AowXN-000BPH-00.ia6432-inbox-ru@f22.mail.ru>
References: <20040202120217.GA9380@cistron.nl>
Reply-To: =?koi8-r?Q?=22?=Peter Lojkin=?koi8-r?Q?=22=20?=<ia6432@inbox.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: =?koi8-r?Q?=22?=Neil Brown=?koi8-r?Q?=22=20?=<neilb@cse.unsw.edu.au>,
	nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1AowXS-0001WY-2B
	for nfs@lists.sourceforge.net; Thu, 05 Feb 2004 19:20:18 -0800
Received: from f22.mail.ru ([194.67.57.55])
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.30)
	id 1AowXQ-0002Cr-7E
	for nfs@lists.sourceforge.net; Thu, 05 Feb 2004 19:20:16 -0800
To: =?koi8-r?Q?=22?=Miquel van Smoorenburg=?koi8-r?Q?=22=20?=<miquels@cistron.nl>
In-Reply-To: <20040202120217.GA9380@cistron.nl>
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

On Mon, 2 Feb 2004 at 13:02:18 +0100 Miquel van Smoorenburg wrote:

> Turns out that the "offset" argument is off_t instead of loff_t.
> It isn't used at all (unfortunately), but it _is_ checked for
> sanity, so that's where the error came from.
> 
> Here's the fix: nfsd_commit-loff_t.patch
> 
> Should go into the next -rc, I guess.
should this also be applied to 2.4? the code looks the same...



-------------------------------------------------------
The SF.Net email is sponsored by EclipseCon 2004
Premiere Conference on Open Tools Development and Integration
See the breadth of Eclipse activity. February 3-5 in Anaheim, CA.
http://www.eclipsecon.org/osdn
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
