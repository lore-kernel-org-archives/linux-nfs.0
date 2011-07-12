Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:3005 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751267Ab1GLPtF (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 12 Jul 2011 11:49:05 -0400
Message-ID: <4E1C6CED.3080800@RedHat.com>
Date: Tue, 12 Jul 2011 11:49:01 -0400
From: Steve Dickson <SteveD@redhat.com>
To: Benjamin Coddington <bcodding@uvm.edu>
CC: linux-nfs@vger.kernel.org
Subject: Re: svcgssd problem against libgssapi_krb5
References: <822CE753-04C1-44BE-888A-A258D6737E7A@uvm.edu> <FE208962-EC0E-4880-8814-63E11A847AD4@uvm.edu>
In-Reply-To: <FE208962-EC0E-4880-8814-63E11A847AD4@uvm.edu>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0


On 07/11/2011 02:46 PM, Benjamin Coddington wrote:
> This problem is caused by including -ltirpc, where libtirpc.la lists -lgssglue as a dependency.  Libtool (2.2.6b) then re-evaluates the order of linked libraries putting libgssglue behind libgssapi_krb5.
> 
> I fixed this by specifying -lgssglue with -Wl, which is ignored by libtool:
> 
> GSSGLUE_CFLAGS="-Wl,-lgssglue" ./configure
Hmm... The question I have is why are the .la even coming into play?
The libs should be dynamically loaded...

steved.

> 
> Ben
> 
> On Jul 11, 2011, at 12:30 PM, Benjamin Coddington wrote:
> 
>> I have a problem building svcgssd from nfs-utils-1.2.3:
>>
>> svcgssd[15145]: DEBUG: serialize_krb5_ctx: lucid version!
>> svcgssd[15145]: ERROR: GSS-API: error in gss_export_lucid_sec_context(): GSS_S_NO_CONTEXT (No context has been established) - (0x00007fff)
>> svcgssd[15145]: ERROR: failed serializing krb5 context for kernel
>> svcgssd[15145]: WARNING: handle_nullreq: serialize_context_for_kernel failed
>>
>> I found that the svcgssd I built ran differently than the one that works from a major distro.
>>
>> My broken one does this:
>>
>> gssint_mechglue_initialize_library () at g_initialize.c:135
>> 135	{
>> (gdb) bt
>> #0  gssint_mechglue_initialize_library () at g_initialize.c:135
>> #1  0x00007ffff79a9f75 in gss_indicate_mechs (minorStatus=0x7fffffffe50c, mechSet_out=0x7fffffffe500) at g_initialize.c:220
>> #2  0x00000000004021ae in gssd_check_mechs () at gss_util.c:241
>> #3  0x0000000000402777 in main (argc=3, argv=<value optimized out>) at svcgssd.c:239
>>
>>
>> But if I remove -lgssapi_krb5, svcgssd works fine, and behaves like the one from the distro:
>>
>> gss_initialize () at g_initialize.c:148
>> 148	{
>> (gdb) bt
>> #0  gss_initialize () at g_initialize.c:148
>> #1  0x00007ffff6e82f6e in gss_indicate_mechs (minor_status=0x7fffffffe50c, mech_set=0x7fffffffe500) at g_indicate_mechs.c:54
>> #2  0x000000000040216e in gssd_check_mechs () at gss_util.c:241
>> #3  0x0000000000402737 in main (argc=3, argv=<value optimized out>) at svcgssd.c:239
>>
>>
>> Ben--
>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
