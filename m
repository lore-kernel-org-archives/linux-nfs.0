From: "Kevin Coffman" <kwc@citi.umich.edu>
Subject: Re: Kerberized NFSv4 with AD - Errors received
Date: Tue, 30 Oct 2007 12:40:36 -0400
Message-ID: <4d569c330710300940q7ee25e95g47ab5395f4917e34@mail.gmail.com>
References: <cf8a6bbc0710300914r6302613emf09dc5d445cbe586@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: "Felderi Santiago" <cibao5@gmail.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Imu8m-0000bt-89
	for nfs@lists.sourceforge.net; Tue, 30 Oct 2007 09:40:33 -0700
Received: from rv-out-0910.google.com ([209.85.198.189])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1Imu8q-0000IC-Nq
	for nfs@lists.sourceforge.net; Tue, 30 Oct 2007 09:40:38 -0700
Received: by rv-out-0910.google.com with SMTP id g11so6992560rvb
	for <nfs@lists.sourceforge.net>; Tue, 30 Oct 2007 09:40:36 -0700 (PDT)
In-Reply-To: <cf8a6bbc0710300914r6302613emf09dc5d445cbe586@mail.gmail.com>
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

On 10/30/07, Felderi Santiago <cibao5@gmail.com> wrote:
> Hello everyone,
>
> I am working on trying to get Kerberized NFSv4 working with AD.  At this
> point everything seems to be setup correctly.  The machine has been joined
> to AD, the keytab has been updated with the appropriate entries and the
> computer account has the appropriate servicePrincipal and userPrincipal
> Names.  The Kerberized NFS Share resides on a Filer.
>
> When trying to mount the share on the client side I get the following error
> messages.
>
> Does anyone understand why we're getting this error?  Any help or insight
> would be very appreciated.
>
> Thanks!
>
> Oct 29 20:03:33 dev-unix-shell01 rpc.gssd[3284]: processing client list Oct
> 29 20:03:33 dev-unix-shell01 rpc.gssd[3284]: processing client list Oct 29
> 20:03:33 dev-unix-shell01 rpc.gssd[3284]: handling krb5 upcall Oct 29
> 20:03:33 dev-unix-shell01 rpc.gssd[3284]: Using keytab file
> '/etc/krb5.keytab'
> Oct 29 20:03:33 dev-unix-shell01 rpc.gssd[3284]: INFO: Credentials in CC
> 'FILE:/tmp/krb5cc_machine_<DOMAIN>are good until 1193722038
> Oct 29 20:03:33 dev-unix-shell01 rpc.gssd[3284]: using
> FILE:/tmp/krb5cc_machine_<DOMAIN> as credentials cache for
> machine creds Oct 29 20:03:33 dev-unix-shell01 rpc.gssd[3284]: using
> environment variable to select krb5 ccache
> FILE:/tmp/krb5cc_machine_<DOMAIN>
> Oct 29 20:03:33 dev-unix-shell01 rpc.gssd[3284]: creating context using euid
> 0 (save_uid 0) Oct 29 20:03:33 dev-unix-shell01 rpc.gssd[3284]: creating tcp
> client for server prod-fs-sv1.<domainname>
> Oct 29 20:03:34 dev-unix-shell01 rpc.gssd[3284]: creating context with
> server nfs@prod-fs-sv1.<domain_name>
> Oct 29 20:03:34 dev-unix-shell01 rpc.gssd[3284]: DEBUG:
> serialize_krb5_ctx: lucid version!
> Oct 29 20:03:34 dev-unix-shell01 rpc.gssd[3284]: doing downcall Oct 29
> 20:03:34 dev-unix-shell01 rpc.gssd[3284]: processing client list

There is no error message here.  This is all normal, apparently
successful, debug output.

What error are you seeing?

BTW, you said, "the keytab has been updated with the appropriate
entries".  I'm not sure what this means, but I hope it does not mean
that keys for non-supported enctypes were simply manually removed from
the keytab file using ktutil.

K.C.

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
