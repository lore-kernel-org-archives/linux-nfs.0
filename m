Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-gy0-f174.google.com ([209.85.160.174]:58511 "EHLO
	mail-gy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753238Ab0DONZ5 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 15 Apr 2010 09:25:57 -0400
Received: by gyg13 with SMTP id 13so737359gyg.19
        for <linux-nfs@vger.kernel.org>; Thu, 15 Apr 2010 06:25:56 -0700 (PDT)
In-Reply-To: <4BC6FF80.80506@RedHat.com>
References: <1271272729-24422-1-git-send-email-steved@redhat.com>
	 <1271272729-24422-3-git-send-email-steved@redhat.com>
	 <z2j4d569c331004141258y2f16a82ga1aa7826d665b3a9@mail.gmail.com>
	 <4BC6FF80.80506@RedHat.com>
Date: Thu, 15 Apr 2010 09:25:51 -0400
Message-ID: <n2p4d569c331004150625m69a08357l93eac48153d1b2a4@mail.gmail.com>
Subject: Re: [PATCH 2/3] Try to use kernel function to determine supported
	Kerberos enctypes.
From: Kevin Coffman <kwc@citi.umich.edu>
To: Steve Dickson <SteveD@redhat.com>
Cc: linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Thu, Apr 15, 2010 at 7:58 AM, Steve Dickson <SteveD@redhat.com> wrote:
> Hey Kevin,
>
> On 04/14/2010 03:58 PM, Kevin Coffman wrote:
>>
>> The global krb5_enctypes array was used when the list was being read
>> once from a file.  With the list now coming up with each request in
>> the updated upcall, I think the list obtained in the upcall should be
>> added to the clnt_info structure and then passed to the
>> limit_krb5_enctypes function as a parameter.
> I took a look at move the krb5_enctypes array in to the clnt_info structure
> and I'm thinking it might be better to keep it as global variable.
> Here is my reasoning...
>
> The "enctypes=" string that comes up in the upcall is basically a
> static string. Yeah I know it could change but that's highly unlikely
> any time soon. So if we put the krb5_enctypes array in the clnt_info
> structure we would have to parse that (static) string on *every* upcall,
> since the clnt_info structures are dynamically allocated. So
> parsing a static string on every upcall does not make sense to me.
>
> Keeping the supported enctypes in a global variable allow us to
> parse the string once and when it changes (which will never happen
> dynamically). So if the first enctypes values are cached, all that
> parsing become a simple strcmp()... ala:
>
> +parse_enctypes(char *enctypes)
> +{
> +       int n = 0;
> +       char *curr, *comma;
> +       int i;
> +       static char *cached_types;
> +
> +       if (cached_types && strcmp(cached_types, enctypes) == 0)
> +               return 0;
>
>
> Makes sense? Am I missing something??
>
> steved.

I originally missed the addition of cached_types.  I guess this is fine.

K.C.
