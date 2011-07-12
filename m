Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp2.uvm.edu ([132.198.101.169]:55560 "EHLO smtp2.uvm.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753855Ab1GLTCj convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 12 Jul 2011 15:02:39 -0400
Subject: Re: svcgssd problem against libgssapi_krb5
Content-Type: text/plain; charset=us-ascii
From: Benjamin Coddington <bcodding@uvm.edu>
In-Reply-To: <4E1C6CED.3080800@RedHat.com>
Date: Tue, 12 Jul 2011 15:02:28 -0400
Cc: linux-nfs@vger.kernel.org
Message-Id: <FB8FC6DC-C49F-478D-A7EC-0FE8AD031700@uvm.edu>
References: <822CE753-04C1-44BE-888A-A258D6737E7A@uvm.edu> <FE208962-EC0E-4880-8814-63E11A847AD4@uvm.edu> <4E1C6CED.3080800@RedHat.com>
To: Steve Dickson <SteveD@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Jul 12, 2011, at 11:49 AM, Steve Dickson wrote:

> 
> On 07/11/2011 02:46 PM, Benjamin Coddington wrote:
>> This problem is caused by including -ltirpc, where libtirpc.la lists -lgssglue as a dependency.  Libtool (2.2.6b) then re-evaluates the order of linked libraries putting libgssglue behind libgssapi_krb5.
>> 
>> I fixed this by specifying -lgssglue with -Wl, which is ignored by libtool:
>> 
>> GSSGLUE_CFLAGS="-Wl,-lgssglue" ./configure
> Hmm... The question I have is why are the .la even coming into play?
> The libs should be dynamically loaded...

This is what happens with the vanilla configure:

[rpmbuilder@rh6-64-build gssd]$ rm svcgssd
[rpmbuilder@rh6-64-build gssd]$ make
/bin/sh ../../libtool --tag=CC   --mode=link gcc -Wall -Wextra -Wstrict-prototypes  -pipe -g -O2  -I/usr/include/gssglue    -g -O2   -o svcgssd svcgssd-context.o svcgssd-context_mit.o svcgssd-context_heimdal.o svcgssd-context_lucid.o svcgssd-context_spkm3.o svcgssd-gss_util.o svcgssd-gss_oids.o svcgssd-err_util.o svcgssd-svcgssd.o svcgssd-svcgssd_main_loop.o svcgssd-svcgssd_mech2file.o svcgssd-svcgssd_proc.o ../../support/nfs/libnfs.a  -lgssglue -ldl   -lnfsidmap -lgssapi_krb5 -lkrb5 -lk5crypto -lcom_err -ltirpc 
libtool: link: warning: library `/lib64/libtirpc.la' was moved.
libtool: link: warning: library `/lib64/libtirpc.la' was moved.
libtool: link: gcc -Wall -Wextra -Wstrict-prototypes -pipe -g -O2 -I/usr/include/gssglue -g -O2 -o svcgssd svcgssd-context.o svcgssd-context_mit.o svcgssd-context_heimdal.o svcgssd-context_lucid.o svcgssd-context_spkm3.o svcgssd-gss_util.o svcgssd-gss_oids.o svcgssd-err_util.o svcgssd-svcgssd.o svcgssd-svcgssd_main_loop.o svcgssd-svcgssd_mech2file.o svcgssd-svcgssd_proc.o  ../../support/nfs/libnfs.a /usr/lib64/libnfsidmap.so -lgssapi_krb5 -lkrb5 -lk5crypto -lcom_err /lib64/libtirpc.so -lnsl -lgssglue -ldl -lpthread

Ben


>> 
>> On Jul 11, 2011, at 12:30 PM, Benjamin Coddington wrote:
>> 
>>> I have a problem building svcgssd from nfs-utils-1.2.3:
>>> 
>>> svcgssd[15145]: DEBUG: serialize_krb5_ctx: lucid version!
>>> svcgssd[15145]: ERROR: GSS-API: error in gss_export_lucid_sec_context(): GSS_S_NO_CONTEXT (No context has been established) - (0x00007fff)
>>> svcgssd[15145]: ERROR: failed serializing krb5 context for kernel
>>> svcgssd[15145]: WARNING: handle_nullreq: serialize_context_for_kernel failed
>>> 
>>> I found that the svcgssd I built ran differently than the one that works from a major distro.
>>> 
>>> My broken one does this:
>>> 
>>> gssint_mechglue_initialize_library () at g_initialize.c:135
>>> 135	{
>>> (gdb) bt
>>> #0  gssint_mechglue_initialize_library () at g_initialize.c:135
>>> #1  0x00007ffff79a9f75 in gss_indicate_mechs (minorStatus=0x7fffffffe50c, mechSet_out=0x7fffffffe500) at g_initialize.c:220
>>> #2  0x00000000004021ae in gssd_check_mechs () at gss_util.c:241
>>> #3  0x0000000000402777 in main (argc=3, argv=<value optimized out>) at svcgssd.c:239
>>> 
>>> 
>>> But if I remove -lgssapi_krb5, svcgssd works fine, and behaves like the one from the distro:
>>> 
>>> gss_initialize () at g_initialize.c:148
>>> 148	{
>>> (gdb) bt
>>> #0  gss_initialize () at g_initialize.c:148
>>> #1  0x00007ffff6e82f6e in gss_indicate_mechs (minor_status=0x7fffffffe50c, mech_set=0x7fffffffe500) at g_indicate_mechs.c:54
>>> #2  0x000000000040216e in gssd_check_mechs () at gss_util.c:241
>>> #3  0x0000000000402737 in main (argc=3, argv=<value optimized out>) at svcgssd.c:239
>>> 
>>> 
>>> Ben--
>>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>>> the body of a message to majordomo@vger.kernel.org
>>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>> 
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

