From: Paul Jakma <paul@clubi.ie>
Subject: Re: gss/krb doesnt work with nfsv3?
Date: Wed, 2 Jun 2004 17:47:16 +0100 (IST)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.LNX.4.58.0406021745210.3160@fogarty.jakma.org>
References: <Pine.LNX.4.58.0406021704290.3160@fogarty.jakma.org>
 <20040602164136.GB4123@fieldses.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Linux NFS <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BVYth-0008NB-Ga
	for nfs@lists.sourceforge.net; Wed, 02 Jun 2004 09:47:25 -0700
Received: from hibernia.jakma.org ([212.17.55.49])
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.30)
	id 1BVYtg-0004Lq-Sn
	for nfs@lists.sourceforge.net; Wed, 02 Jun 2004 09:47:25 -0700
To: "J. Bruce Fields" <bfields@fieldses.org>
In-Reply-To: <20040602164136.GB4123@fieldses.org>
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

On Wed, 2 Jun 2004, J. Bruce Fields wrote:

> Yes, and it's working for me.  

Aha.

> What version of nfs-utils is your mountd from? 

Fedora Core 2:

# rpm -q nfs-utils
nfs-utils-1.0.6-22

On both client and server.

> And could I take a look at a trace of the network traffic during
> the failed mount?

Sure, hang on.
 
> --b.

regards,
-- 
Paul Jakma	paul@clubi.ie	paul@jakma.org	Key ID: 64A2FF6A
	warning: do not ever send email to spam@dishone.st
Fortune:
"I don't believe in sweeping social change being manifested by one person, 
unless he has an atomic weapon."
-- Howard Chaykin


-------------------------------------------------------
This SF.Net email is sponsored by the new InstallShield X.
