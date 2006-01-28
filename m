From: Marc Eshel <eshel@almaden.ibm.com>
Subject: Re: virtual hostname support for sm-notify on SuSE
Date: Fri, 27 Jan 2006 18:21:59 -0800
Message-ID: <OF322A73D5.EFCAF050-ON88257104.000C2815-88257104.000CB1F4@us.ibm.com>
References: <20060104060244.76161.qmail@web51613.mail.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: nfs@lists.sourceforge.net, nfs-admin@lists.sourceforge.net,
	Manoj Naik <manoj@almaden.ibm.com>
Return-path: <nfs-admin@lists.sourceforge.net>
In-Reply-To: <20060104060244.76161.qmail@web51613.mail.yahoo.com>
To: okir@suse.de, mehta kiran <kiranmehta1981@yahoo.com>
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

Hi Olaf 
I asked for this fix a couple of years ago, here is the fix for this 
problem.
Marc.

 
--- sm-notify.c.orig             2006-01-27 16:58:47.913561080 -0800
+++ sm-notify.c          2006-01-27 16:59:11.855921288 -0800
@@ -183,12 +183,16 @@ notify(void)
                 sin.sin_family = AF_INET;
 
                 /* Bind source IP if provided on command line */
-                if (opt_srcaddr
-                 && inet_aton(opt_srcaddr, &sin.sin_addr) == 0) {
-                                fprintf(stderr,
-                                                "Not a valid IP address: 
\"%s\"\n",
-                                                opt_srcaddr);
-                                exit(1);
+                if (opt_srcaddr) {
+                                struct hostent *hp = 
gethostbyname(opt_srcaddr);
+                                if (hp)
+                                                sin.sin_addr = *(struct 
in_addr *)hp->h_addr;
+                                else {
+                                                fprintf(stderr,
+                                                                "Not a 
valid IP address: \"%s\"\n",
+ opt_srcaddr);
+                                                exit(1);
+                                }
                 }
 
                 /* Use source port if provided on the command line,

-------------------------------------------------------------------------------------------------------------------------------
nfs-admin@lists.sourceforge.net wrote on 01/03/2006 10:02:44 PM:

> Hi,
>      I have noticed that
>      sm-notify -v <virtual ip> works 
>      while sm-notify -v <virtual name> does not work.
>      Virtual name may be required if nfs server fails 
>      over across subnets.
> 
> 
> thanks,
>  kiran

> _______________________________________________
> NFS maillist  -  NFS@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/nfs



-------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc. Do you grep through log files
for problems?  Stop!  Download the new AJAX search engine that makes
searching your log files as easy as surfing the  web.  DOWNLOAD SPLUNK!
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=103432&bid=230486&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
