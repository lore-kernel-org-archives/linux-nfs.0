From: "Felderi Santiago" <cibao5@gmail.com>
Subject: Kerberized NFSv4 with AD - Errors received
Date: Tue, 30 Oct 2007 12:14:45 -0400
Message-ID: <cf8a6bbc0710300914r6302613emf09dc5d445cbe586@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============1218202425=="
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Imtjn-0006Jw-3M
	for nfs@lists.sourceforge.net; Tue, 30 Oct 2007 09:14:43 -0700
Received: from ug-out-1314.google.com ([66.249.92.168])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1Imtjr-00058v-4j
	for nfs@lists.sourceforge.net; Tue, 30 Oct 2007 09:14:48 -0700
Received: by ug-out-1314.google.com with SMTP id m2so139646uge
	for <nfs@lists.sourceforge.net>; Tue, 30 Oct 2007 09:14:46 -0700 (PDT)
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

--===============1218202425==
Content-Type: multipart/alternative;
	boundary="----=_Part_1220_11522699.1193760885915"

------=_Part_1220_11522699.1193760885915
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

Hello everyone,

I am working on trying to get Kerberized NFSv4 working with AD.  At this
point everything seems to be setup correctly.  The machine has been joined
to AD, the keytab has been updated with the appropriate entries and the
computer account has the appropriate servicePrincipal and userPrincipal
Names.  The Kerberized NFS Share resides on a Filer.

When trying to mount the share on the client side I get the following error
messages.

Does anyone understand why we're getting this error?  Any help or insight
would be very appreciated.

Thanks!

Oct 29 20:03:33 dev-unix-shell01 rpc.gssd[3284]: processing client list Oct
29 20:03:33 dev-unix-shell01 rpc.gssd[3284]: processing client list Oct 29
20:03:33 dev-unix-shell01 rpc.gssd[3284]: handling krb5 upcall Oct 29
20:03:33 dev-unix-shell01 rpc.gssd[3284]: Using keytab file
'/etc/krb5.keytab'
Oct 29 20:03:33 dev-unix-shell01 rpc.gssd[3284]: INFO: Credentials in CC
'FILE:/tmp/krb5cc_machine_<DOMAIN>are good until 1193722038 Oct 29 20:03:33
dev-unix-shell01 rpc.gssd[3284]: using FILE:/tmp/krb5cc_machine_<DOMAIN> as
credentials cache for machine creds Oct 29 20:03:33 dev-unix-shell01
rpc.gssd[3284]: using environment variable to select krb5 ccache
FILE:/tmp/krb5cc_machine_<DOMAIN>
Oct 29 20:03:33 dev-unix-shell01 rpc.gssd[3284]: creating context using euid
0 (save_uid 0) Oct 29 20:03:33 dev-unix-shell01 rpc.gssd[3284]: creating tcp
client for server prod-fs-sv1.<domainname>
Oct 29 20:03:34 dev-unix-shell01 rpc.gssd[3284]: creating context with
server nfs@prod-fs-sv1.<domain_name>
Oct 29 20:03:34 dev-unix-shell01 rpc.gssd[3284]: DEBUG:
serialize_krb5_ctx: lucid version!
Oct 29 20:03:34 dev-unix-shell01 rpc.gssd[3284]: doing downcall Oct 29
20:03:34 dev-unix-shell01 rpc.gssd[3284]: processing client list

------=_Part_1220_11522699.1193760885915
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

<div>Hello everyone,</div>
<div>&nbsp;</div>
<div>I am working on trying to get Kerberized NFSv4 working with AD.&nbsp; At this point everything seems to be setup correctly.&nbsp; The machine has been joined to AD, the keytab has been updated with the appropriate entries and the computer account has the appropriate servicePrincipal and userPrincipal Names.&nbsp; The Kerberized NFS Share resides on a Filer.
</div>
<div>&nbsp;</div>
<div>When trying to mount the share on the client side I get the following error messages.</div>
<div>&nbsp;</div>
<div>Does anyone understand why we&#39;re getting this error?&nbsp; Any help or insight would be very appreciated.</div>
<div>&nbsp;</div>
<div>Thanks!</div>
<p>Oct 29 20:03:33 dev-unix-shell01 rpc.gssd[3284]: processing client list Oct 29 20:03:33 dev-unix-shell01 rpc.gssd[3284]: processing client list Oct 29 20:03:33 dev-unix-shell01 rpc.gssd[3284]: handling krb5 upcall Oct 29 20:03:33 dev-unix-shell01 
rpc.gssd[3284]: Using keytab file &#39;/etc/krb5.keytab&#39;<br>Oct 29 20:03:33 dev-unix-shell01 rpc.gssd[3284]: INFO: Credentials in CC &#39;FILE:/tmp/krb5cc_machine_&lt;DOMAIN&gt;are good until 1193722038 Oct 29 20:03:33 dev-unix-shell01 
rpc.gssd[3284]: using FILE:/tmp/krb5cc_machine_&lt;DOMAIN&gt; as credentials cache for machine creds Oct 29 20:03:33 dev-unix-shell01 rpc.gssd[3284]: using environment variable to select krb5 ccache FILE:/tmp/krb5cc_machine_&lt;DOMAIN&gt;
<br>Oct 29 20:03:33 dev-unix-shell01 rpc.gssd[3284]: creating context using euid 0 (save_uid 0) Oct 29 20:03:33 dev-unix-shell01 rpc.gssd[3284]: creating tcp client for server prod-fs-sv1.&lt;domainname&gt;<br>Oct 29 20:03:34 dev-unix-shell01 
rpc.gssd[3284]: creating context with server <a href="mailto:nfs@prod-fs-sv1.&lt;domain_name&gt;">nfs@prod-fs-sv1.&lt;domain_name&gt;</a><br>Oct 29 20:03:34 dev-unix-shell01 rpc.gssd[3284]: DEBUG: <br>serialize_krb5_ctx: lucid version!
<br>Oct 29 20:03:34 dev-unix-shell01 rpc.gssd[3284]: doing downcall Oct 29 20:03:34 dev-unix-shell01 rpc.gssd[3284]: processing client list</p>
<p>&nbsp;</p>

------=_Part_1220_11522699.1193760885915--


--===============1218202425==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
--===============1218202425==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--===============1218202425==--
