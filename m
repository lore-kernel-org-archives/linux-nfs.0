Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:6548 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753355Ab0DOL67 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 15 Apr 2010 07:58:59 -0400
Message-ID: <4BC6FF80.80506@RedHat.com>
Date: Thu, 15 Apr 2010 07:58:56 -0400
From: Steve Dickson <SteveD@redhat.com>
To: Kevin Coffman <kwc@citi.umich.edu>
CC: linux-nfs@vger.kernel.org
Subject: Re: [PATCH 2/3] Try to use kernel function to determine supported
 	Kerberos enctypes.
References: <1271272729-24422-1-git-send-email-steved@redhat.com>	 <1271272729-24422-3-git-send-email-steved@redhat.com> <z2j4d569c331004141258y2f16a82ga1aa7826d665b3a9@mail.gmail.com>
In-Reply-To: <z2j4d569c331004141258y2f16a82ga1aa7826d665b3a9@mail.gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hey Kevin,

On 04/14/2010 03:58 PM, Kevin Coffman wrote:
> 
> The global krb5_enctypes array was used when the list was being read
> once from a file.  With the list now coming up with each request in
> the updated upcall, I think the list obtained in the upcall should be
> added to the clnt_info structure and then passed to the
> limit_krb5_enctypes function as a parameter.
I took a look at move the krb5_enctypes array in to the clnt_info structure
and I'm thinking it might be better to keep it as global variable. 
Here is my reasoning... 

The "enctypes=" string that comes up in the upcall is basically a 
static string. Yeah I know it could change but that's highly unlikely
any time soon. So if we put the krb5_enctypes array in the clnt_info
structure we would have to parse that (static) string on *every* upcall,
since the clnt_info structures are dynamically allocated. So
parsing a static string on every upcall does not make sense to me.

Keeping the supported enctypes in a global variable allow us to
parse the string once and when it changes (which will never happen
dynamically). So if the first enctypes values are cached, all that
parsing become a simple strcmp()... ala:
 
+parse_enctypes(char *enctypes)
+{
+	int n = 0;
+	char *curr, *comma;
+	int i;
+	static char *cached_types;
+
+	if (cached_types && strcmp(cached_types, enctypes) == 0)
+		return 0;


Makes sense? Am I missing something??

steved.
