Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail1.windriver.com ([147.11.146.13]:45418 "EHLO
	mail1.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752074Ab3AUU77 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 21 Jan 2013 15:59:59 -0500
Message-ID: <50FDAC3A.3040806@windriver.com>
Date: Mon, 21 Jan 2013 15:59:38 -0500
From: Yao Zhao <yao.zhao@windriver.com>
MIME-Version: 1.0
To: Steve Dickson <SteveD@redhat.com>
CC: "J. Bruce Fields" <bfields@fieldses.org>, <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH]fix bugs and compiling warnings in libgssglue
References: <50577508.90004@windriver.com> <20121019122650.GA20324@fieldses.org> <50816199.9000900@RedHat.com>
In-Reply-To: <50816199.9000900@RedHat.com>
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 12-10-19 10:20 AM, Steve Dickson wrote:
>
> On 19/10/12 08:26, J. Bruce Fields wrote:
>> Steve, is it you that maintains libgssglue now?
> Yes, I do. Thanks for the ping. I did miss this...
Hi Steve,

Just want to follow up whether these are fixed?

thanks,
yao
> steved.
>
>> --b.
>>
>> On Mon, Sep 17, 2012 at 03:07:52PM -0400, Yao Zhao wrote:
>>> Hi,
>>>
>>> The 4 attached patches fixed a couple of warnings and bug found when
>>> compiling libgssglue.
>>>
>>> thanks,
>>> yao
>>> --- a/src/g_canon_name.c
>>> +++ b/src/g_canon_name.c
>>> fix the bug:
>>> g_canon_name.c:125:5: warning: passing argument 2 of '__gss_copy_namebuf' from incompatible pointer type [enabled by default]
>>>
>>> the 2nd argument of __gss_copy_namebuf should be address of *gss_buffer_t, \
>>> but a *gss_buffer_t is assigned.
>>>
>>> what __gss_copy_namebuf does is to alloc memory for a gss_buffer_desc and \
>>> copy from src and return its address.
>>>
>>> if following code failed, gss_release_name will free \
>>> union_canon_name->external_name.value if it is not NULL.
>>>
>>> OM_uint32 __gss_copy_namebuf(src, dest)
>>>      gss_buffer_t   src;
>>>      gss_buffer_t   *dest;
>>>
>>> typedef struct gss_union_name_t {
>>> 	gss_mechanism		gss_mech;
>>> 	gss_OID			name_type;
>>> 	gss_buffer_desc		external_name;
>>> 	/*
>>> 	 * These last two fields are only filled in for mechanism
>>> 	 * names.
>>> 	 */
>>> 	gss_OID			mech_type;
>>> 	gss_name_t		mech_name;
>>> } gss_union_name_desc, *gss_union_name_t;
>>>
>>> typedef struct gss_buffer_desc_struct {
>>>        size_t length;
>>>        void FAR *value;
>>> } gss_buffer_desc, FAR *gss_buffer_t;
>>>
>>> Upstream-Status: Pending
>>> Signed-off-by: Yao Zhao <yao.zhao@windriver.com>
>>>
>>> @@ -121,11 +121,17 @@ gss_canonicalize_name (OM_uint32 *minor_
>>>   
>>>       union_canon_name->mech_name = mech_name;
>>>   
>>> -    status = __gss_copy_namebuf(&union_input_name->external_name,
>>> -				&union_canon_name->external_name);
>>> -    if (status != GSS_S_COMPLETE)
>>> -	goto failure;
>>> +    union_canon_name->external_name.value = (void*) malloc(
>>> +                      union_input_name->external_name.length + 1);
>>> +    if (!union_canon_name->external_name.value)
>>> +        goto failure;
>>>   
>>> +    memcpy(union_canon_name->external_name.value,
>>> +           union_input_name->external_name.value,
>>> +           union_input_name->external_name.length);
>>> +    union_canon_name->external_name.length =
>>> +                      union_input_name->external_name.length;
>>> +
>>>       if (union_input_name->name_type != GSS_C_NO_OID) {
>>>   	status = generic_gss_copy_oid(minor_status,
>>>   				      union_input_name->name_type,
>>> diff --git a/src/g_initialize.c b/src1/g_initialize.c
>>> index 82fcce1..200f173 100644
>>> --- a/src/g_initialize.c
>>> +++ b/src/g_initialize.c
>>>
>>> Fix the warning for getuid, geteuid
>>> g_initialize.c: In function 'linux_initialize':
>>> g_initialize.c:275:5: warning: implicit declaration of function 'getuid' [-Wimplicit-function-declaration]
>>> g_initialize.c:275:5: warning: implicit declaration of function 'geteuid' [-Wimplicit-function-declaration]
>>>
>>> Upstream-Status: Pending
>>> Signed-off-by: Yao Zhao <yao.zhao@windriver.com>
>>>
>>> @@ -29,6 +29,8 @@
>>>   #include "mglueP.h"
>>>   #include <stdlib.h>
>>>   
>>> +#include <unistd.h>   /*getuid, geteuid */
>>> +#include <sys/types.h>
>>>   #include <stdio.h>
>>>   #include <string.h>
>>>   #include <ctype.h>
>>> --- a/src/g_inq_cred.c
>>> +++ b/src/g_inq_cred.c
>>> 1) add free if malloc failed for (*mechanisms)->elements
>>> 2) g_inq_cred.c: In function 'gss_inquire_cred':
>>> g_inq_cred.c:161:8: warning: passing argument 3 of 'generic_gss_copy_oid' from incompatible pointer type [enabled by default]
>>>
>>> Upstream-Status: Pending
>>> Signed-off-by: Yao Zhao <yao.zhao@windriver.com>
>>>
>>> @@ -152,13 +152,15 @@ gss_OID_set *		mechanisms;
>>>   			     union_cred->count);
>>>   	if ((*mechanisms)->elements == NULL) {
>>>   	    *minor_status = ENOMEM;
>>> +	    free(*mechanisms);
>>> +	    *mechanisms = GSS_C_NO_OID_SET;
>>>   	    return (GSS_S_FAILURE);
>>>   	}
>>>   
>>>   	for (i=0; i < union_cred->count; i++) {
>>> -	    status = generic_gss_copy_oid(minor_status,
>>> +	    status = generic_gss_add_oid_set_member(minor_status,
>>>   	    				  &union_cred->mechs_array[i],
>>> -					  &((*mechanisms)->elements[i]));
>>> +					  mechanisms);
>>>   	    if (status != GSS_S_COMPLETE)
>>>   	        break;
>>>   	}
>>> --- a/src/mglueP.h
>>> +++ b/src/mglueP.h
>>> fix the warning:
>>> warning: implicit declaration of function 'generic_gss_copy_oid_set' [-Wimplicit-function-declaration]
>>>
>>> Upstream-Status: Pending
>>> Signed-off-by: Yao Zhao <yao.zhao@windriver.com>
>>>
>>> @@ -447,6 +447,12 @@ OM_uint32 generic_gss_copy_oid
>>>   	    gss_OID *		/* new_oid */
>>>   	    );
>>>   
>>> +OM_uint32 generic_gss_copy_oid_set
>>> +	   (OM_uint32 *minor_status,	/* minor_status */
>>> +	    const gss_OID_set_desc * const oidset,	/* oid */
>>> +	    gss_OID_set *new_oidset			/* new_oid */
>>> +	   );
>>> +
>>>   OM_uint32 generic_gss_create_empty_oid_set
>>>   	   (OM_uint32 *,	/* minor_status */
>>>   	    gss_OID_set *	/* oid_set */

