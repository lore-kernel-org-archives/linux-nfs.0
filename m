From: Steve Dickson <SteveD@redhat.com>
Subject: Re: [PATCH] sm-notify: perform DNS lookup in the background.
Date: Wed, 16 Jul 2008 14:43:54 -0400
Message-ID: <487E416A.4050007@RedHat.com>
References: <18556.16890.235207.711721@notabene.brown> <76bd70e30807150831l294c7f0as8ba53709e71d5827@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Neil Brown <neilb@suse.de>, linux-nfs@vger.kernel.org
To: chucklever@gmail.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:40856 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753589AbYGPSo3 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 16 Jul 2008 14:44:29 -0400
In-Reply-To: <76bd70e30807150831l294c7f0as8ba53709e71d5827-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



Chuck Lever wrote:
> On Tue, Jul 15, 2008 at 2:21 AM, Neil Brown <neilb@suse.de> wrote:

>> If an NFS server has no network connectivity when it reboots,
>> it will block in sm-notify waiting for DNS lookup for a potentially
>> large number of hosts.  This is not helpful and just annoys the
>> sysadmin.
>>
>> So do the DNS lookup in the backgrounded phase of sm-notify,
>> before sending off the NOTIFY requests.
> 
> Good idea.  A couple of minor comments below.
> 

> 
> Arguably it would be cleaner architecturally if the DNS lookup were in
> notify_host().  Since doing it in notify() means you will be looking
> up these addresses on retries, maybe the host_lookup() call should be
> integrated into the "If we retransmitted 4 times" logic.  That would
> be an opportunity to fix the addrinfo leak in there.
> 
> [Note that freeaddrinfo(3) simply walks the list of addrinfo
> structures and frees them.  By setting ai_next to NULL in some of the
> addrinfo structures, sm-notify is orphaning them -- freeaddrinfo(3)
> will never find them].
> 

>>                        /* Set the timeout for this call, using an
>> @@ -532,15 +546,6 @@ get_hosts(const char *dirname)
> 
> You should probably fix the documenting comment for get_hosts() --
> "convert them to host entries" might be more precise.
> 


I believe the following patch address those minor comments... true?

Signed-off-by: Steve Dickson <steved@redhat.com>

diff --git a/utils/statd/sm-notify.c b/utils/statd/sm-notify.c
index bb67c37..2fc8ec6 100644
--- a/utils/statd/sm-notify.c
+++ b/utils/statd/sm-notify.c
@@ -76,7 +76,7 @@ static int		log_syslog = 0;
 
 static unsigned int	nsm_get_state(int);
 static void		notify(void);
-static void		notify_host(int, struct nsm_host *);
+static int		notify_host(int, struct nsm_host *);
 static void		recv_reply(int);
 static void		backup_hosts(const char *, const char *);
 static void		get_hosts(const char *);
@@ -286,7 +286,13 @@ notify(void)
 			hp = hosts;
 			hosts = hp->next;
 
-			notify_host(sock, hp);
+			if (notify_host(sock, hp)){
+				unlink(hp->path);
+				free(hp->name);
+				free(hp->path);
+				free(hp);
+				continue;
+			}
 
 			/* Set the timeout for this call, using an
 			   exponential timeout strategy */
@@ -318,7 +324,7 @@ notify(void)
 /*
  * Send notification to a single host
  */
-void
+int
 notify_host(int sock, struct nsm_host *host)
 {
 	static unsigned int	xid = 0;
@@ -331,6 +337,15 @@ notify_host(int sock, struct nsm_host *host)
 	if (!host->xid)
 		host->xid = xid++;
 
+	if (hp->ai == NULL) {
+		hp->ai = host_lookup(AF_UNSPEC, hp->name);
+		if (hp->ai == NULL)
+			nsm_log(LOG_WARNING,
+				"%s doesn't seem to be a valid address,"
+				" skipped", hp->name);
+		return 1;
+	}
+
 	memset(msgbuf, 0, sizeof(msgbuf));
 	p = msgbuf;
 	*p++ = htonl(host->xid);
@@ -349,7 +364,6 @@ notify_host(int sock, struct nsm_host *host)
 		while ( *next )
 			next = & (*next)->ai_next;
 		*next = hold;
-		hold->ai_next = NULL;
 		memcpy(&host->addr, hold->ai_addr, hold->ai_addrlen);
 		addr_set_port(&host->addr, 0);
 		host->retries = 0;
@@ -394,7 +408,11 @@ notify_host(int sock, struct nsm_host *host)
 	}
 	len = (p - msgbuf) << 2;
 
-	sendto(sock, msgbuf, len, 0, (struct sockaddr *) &dest, sizeof(dest));
+	if (sendto(sock, msgbuf, len, 0, (struct sockaddr *) &dest, sizeof(dest)) < 0)
+		nsm_log(LOG_WARNING, "Sending Reboot Notification to "
+			"'%s' failed: errno %d (%s)", host->name, errno, strerror(errno));
+	
+	return 0;
 }
 
 /*
@@ -504,7 +522,7 @@ backup_hosts(const char *dirname, const char *bakname)
 }
 
 /*
- * Get all entries from sm.bak and convert them to host names
+ * Get all entries from sm.bak and convert them to host entries
  */
 static void
 get_hosts(const char *dirname)
@@ -532,15 +550,6 @@ get_hosts(const char *dirname)
 		if (stat(path, &stb) < 0)
 			continue;
 
-		host->ai = host_lookup(AF_UNSPEC, de->d_name);
-		if (! host->ai) {
-			nsm_log(LOG_WARNING,
-				"%s doesn't seem to be a valid address, skipped",
-				de->d_name);
-			unlink(path);
-			continue;
-		}
-
 		host->last_used = stb.st_mtime;
 		host->timeout = NSM_TIMEOUT;
 		host->path = strdup(path);
