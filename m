From: Denis Vlasenko <vda@ilport.com.ua>
Subject: Re: mountd: needless DNS queries when authenticating client against numeric IP
Date: Sat, 5 Mar 2005 15:58:56 +0200
Message-ID: <200503051557.07721.vda@ilport.com.ua>
References: <200503041424.22897.vda@ilport.com.ua>
Mime-Version: 1.0
Content-Type: Multipart/Mixed;
  boundary="Boundary-00=_gsbKC1GjX9GU7HM"
Cc: Neil Brown <neilb@cse.unsw.edu.au>,
	Trond Myklebust <trond.myklebust@fys.uio.no>, vital@ilport.com.ua
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1D7ZoM-0006wS-S8
	for nfs@lists.sourceforge.net; Sat, 05 Mar 2005 05:59:18 -0800
Received: from [195.66.192.167] (helo=port.imtp.ilyichevsk.odessa.ua)
	by sc8-sf-mx1.sourceforge.net with smtp (Exim 4.41)
	id 1D7ZoL-0000nx-Mc
	for nfs@lists.sourceforge.net; Sat, 05 Mar 2005 05:59:18 -0800
To: nfs@lists.sourceforge.net
In-Reply-To: <200503041424.22897.vda@ilport.com.ua>
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


--Boundary-00=_gsbKC1GjX9GU7HM
Content-Type: text/plain;
  charset="koi8-r"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

On Friday 04 March 2005 14:24, Denis Vlasenko wrote:
> mount 127.0.0.1:/ can fail if DNS is down
> and mountd has been restarted without re-run of exportfs -r,
> because /var/lib/nfs/etab contains wrong hostname ("localhost"
> instead of "127.0.0.1") and mountd cannot determine that
> these are the same. This was explained in my previous mail.
> 
> Here is another, lesser problem:
> 
> If mountd was restarted _with_ prior run of exportfs -r, etab is correct
> and mount succeeds, but with ~10 sec delay because of DNS timeout
[snip]

I've cooked up a patch.
Now my mount 127.0.0.1:/ /mnt/tmp succeeds instantly,
regardless of whether 127.0.0.1 resolves to 'localhost' or not.

This is accomplished by first trying to auth against numeric IP,
and only if that fails, we resolve IP into name and try again.

Please comment/apply.
--
vda



--Boundary-00=_gsbKC1GjX9GU7HM
Content-Type: text/x-diff;
  charset="koi8-r";
  name="auth.c.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename="auth.c.diff"

--- nfs-utils-1.0.7/utils/mountd/auth.c.orig	Mon Dec  6 02:46:40 2004
+++ nfs-utils-1.0.7/utils/mountd/auth.c	Sat Mar  5 15:48:12 2005
@@ -128,34 +128,14 @@ auth_authenticate_internal(char *what, s
 	return exp;
 }
 
-nfs_export *
-auth_authenticate(char *what, struct sockaddr_in *caller, char *path)
+/* NB: frees hp */
+static nfs_export *
+auth_authenticate_helper(char *what, struct sockaddr_in *caller, char *path, char *epath, struct hostent *hp)
 {
-	nfs_export	*exp = NULL;
-	char		epath[MAXPATHLEN+1];
-	char		*p = NULL;
-	struct hostent	*hp = NULL;
-	struct in_addr	addr = caller->sin_addr;
+	char *p = NULL;
+	nfs_export *exp;
 	enum auth_error	error;
 
-	if (path [0] != '/') {
-		xlog(L_WARNING, "bad path in %s request from %s: \"%s\"",
-		     what, inet_ntoa(addr), path);
-		return exp;
-	}
-
-	strncpy(epath, path, sizeof (epath) - 1);
-	epath[sizeof (epath) - 1] = '\0';
-	auth_fixpath(epath); /* strip duplicate '/' etc */
-
-	hp = get_reliable_hostbyaddr((const char*)&caller->sin_addr, sizeof(struct in_addr),
-				     AF_INET);
-	if (!hp)
-		hp = get_hostent((const char*)&caller->sin_addr, sizeof(struct in_addr),
-				     AF_INET);
-	if (!hp)
-		return exp;
-
 	/* Try the longest matching exported pathname. */
 	while (1) {
 		exp = auth_authenticate_internal(what, caller, epath,
@@ -172,12 +152,12 @@ auth_authenticate(char *what, struct soc
 	switch (error) {
 	case bad_path:
 		xlog(L_WARNING, "bad path in %s request from %s: \"%s\"",
-		     what, inet_ntoa(addr), path);
+		     what, inet_ntoa(caller->sin_addr), path);
 		break;
 
 	case unknown_host:
 		xlog(L_WARNING, "%s request from unknown host %s for %s (%s)",
-		     what, inet_ntoa(addr), path, epath);
+		     what, inet_ntoa(caller->sin_addr), path, epath);
 		break;
 
 	case no_entry:
@@ -203,10 +183,40 @@ auth_authenticate(char *what, struct soc
 		xlog(L_NOTICE, "%s request from %s:%d for %s (%s) gave %d",
 		     what, hp->h_name, ntohs(caller->sin_port), path, epath, error);
 	}
+	free (hp);
+	return exp;
+}
+
+nfs_export *
+auth_authenticate(char *what, struct sockaddr_in *caller, char *path)
+{
+	nfs_export	*exp = NULL;
+	char		epath[MAXPATHLEN+1];
+	struct hostent	*hp;
+
+	if (path [0] != '/') {
+		xlog(L_WARNING, "bad path in %s request from %s: \"%s\"",
+		     what, inet_ntoa(caller->sin_addr), path);
+		return NULL;
+	}
 
+	strncpy(epath, path, sizeof (epath) - 1);
+	epath[sizeof (epath) - 1] = '\0';
+	auth_fixpath(epath); /* strip duplicate '/' etc */
+
+	/* try to auth against address */
+	hp = get_hostent((const char*)&caller->sin_addr,
+					sizeof(struct in_addr), AF_INET);
 	if (hp)
-		free (hp);
+		exp = auth_authenticate_helper(what, caller, path, epath, hp);
 
+	/* Retry with resolved name if unsuccessful */
+	if (!exp) {
+		hp = get_reliable_hostbyaddr((const char*)&caller->sin_addr,
+					sizeof(struct in_addr), AF_INET);
+		if (hp)
+			exp = auth_authenticate_helper(what, caller, path, epath, hp);
+	}
 	return exp;
 }
 

--Boundary-00=_gsbKC1GjX9GU7HM--



-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
