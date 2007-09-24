From: Neil Brown <neilb@suse.de>
Subject: Re: Multiple ranges in squash_uids
Date: Mon, 24 Sep 2007 17:21:43 +1000
Message-ID: <18167.25991.404551.826517@notabene.brown>
References: <20070922101154.GA27465@uio.no>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: "Steinar H. Gunderson" <sgunderson@bigfoot.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IZiGK-0007Y4-Tu
	for nfs@lists.sourceforge.net; Mon, 24 Sep 2007 00:21:49 -0700
Received: from cantor2.suse.de ([195.135.220.15] helo=mx2.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IZiGN-0002bP-4e
	for nfs@lists.sourceforge.net; Mon, 24 Sep 2007 00:21:53 -0700
In-Reply-To: message from Steinar H. Gunderson on Saturday September 22
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

On Saturday September 22, sgunderson@bigfoot.com wrote:
> Hi,
> 
> A user recently complained that you cannot use options like
> "squash_uids=1000-1005,2000-3000", even though the manual page says it's
> supported. The issue is that the option tokenizer thinks "2000-3000" is a
> separate option, so although the uid range parser does handle multiple ranges
> correctly, it doesn't work right.
> 
> The user also supplied a patch (see
> http://bugs.debian.org/cgi-bin/bugreport.cgi?msg=5;filename=nfs-utils_parse_squashids_fix.diff;att=1;bug=442370),
> but I'm not sure if it's the best way to do it. Any suggestions?

Yes.... the suggested patch treats a comma followed by a digit
differently from a comma followed by a non-digit.  I agree that is
ugly, though the code in parsesquash does exactly the same thing.

I would rather change the separator character to e.g. ':', like:

diff --git a/support/nfs/exports.c b/support/nfs/exports.c
index c82bb0e..029a4d4 100644
--- a/support/nfs/exports.c
+++ b/support/nfs/exports.c
@@ -678,9 +678,6 @@ parsesquash(char *list, int **idp, int *lenp, char **ep)
 	int	len = *lenp;
 	int	*id = *idp;
 
-	if (**ep)
-	    *--(*ep) = ',';
-
 	do {
 		id0 = parsenum(&cp);
 		if (*cp == '-') {
@@ -697,17 +694,15 @@ parsesquash(char *list, int **idp, int *lenp, char **ep)
 			id = (int *) xrealloc(id, (len + 8) * sizeof(*id));
 		id[len++] = id0;
 		id[len++] = id1;
-		if (!*cp || *cp == ')' || (*cp == ',' && !isdigit(cp[1])))
+		if (cp >= *ep)
 			break;
-		if (*cp != ',') {
+		if (*cp != ':') {
 			syntaxerr("bad uid/gid list");
 			return -1;
 		}
 		cp++;
 	} while(1);
 
-	if (**ep == ',') (*ep)++;
-
 	*lenp = len;
 	*idp = id;
 	return 1;


(plus a patch to fix the manpage)..

except that this is all completely irrelevant to nfs-utils as we don't
support squash_uids or squash_gids, and never have done.
I wonder what manpage the customer was reading when they saw that:

    The manpage shows "squash_uids=0-15,20,25-50" as a valid entry for the
    /etc/exports file.

It appears in exports.man, but is commented out.

NeilBrownm

-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2005.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
