Return-Path: linux-nfs-owner@vger.kernel.org
Received: from e28smtp05.in.ibm.com ([122.248.162.5]:55185 "EHLO
	e28smtp05.in.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755748AbaEAPmZ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 1 May 2014 11:42:25 -0400
Received: from /spool/local
	by e28smtp05.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-nfs@vger.kernel.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Thu, 1 May 2014 21:12:24 +0530
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
To: Dave Chinner <david@fromorbit.com>
Cc: agruen@kernel.org, bfields@fieldses.org, akpm@linux-foundation.org,
        viro@zeniv.linux.org.uk, dhowells@redhat.com,
        linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org
Subject: Re: [PATCH -V1 10/22] richacl: In-memory representation and helper functions
In-Reply-To: <20140429002457.GS15995@dastard>
References: <1398615293-22931-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com> <1398615293-22931-11-git-send-email-aneesh.kumar@linux.vnet.ibm.com> <20140429002457.GS15995@dastard>
Date: Thu, 01 May 2014 21:12:15 +0530
Message-ID: <87d2fxbj54.fsf@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Dave Chinner <david@fromorbit.com> writes:

> On Sun, Apr 27, 2014 at 09:44:41PM +0530, Aneesh Kumar K.V wrote:
>> From: Andreas Gruenbacher <agruen@kernel.org>
>> 
>> A richacl consists of an NFSv4 acl and an owner, group, and other mask.
>> These three masks correspond to the owner, group, and other file
>> permission bits, but they contain NFSv4 permissions instead of POSIX
>> permissions.
>> 
>> Each entry in the NFSv4 acl applies to the file owner (OWNER@), the
>> owning group (GROUP@), literally everyone (EVERYONE@), or to a specific
>> uid or gid.
>> 
>> As in the standard POSIX file permission model, each process is the
>> owner, group, or other file class.  A richacl grants a requested access
>> only if the NFSv4 acl in the richacl grants the access (according to the
>> NFSv4 permission check algorithm), and the file mask that applies to the
>> process includes the requested permissions.
>> 
>> Signed-off-by: Andreas Gruenbacher <agruen@kernel.org>
>> Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
> ....
>> +
>> +/**
>> + * richace_is_same_identifier  -  are both identifiers the same?
>> + */
>> +int
>> +richace_is_same_identifier(const struct richace *a, const struct richace *b)
>> +{
>> +#define WHO_FLAGS (ACE4_SPECIAL_WHO | ACE4_IDENTIFIER_GROUP)
>> +	if ((a->e_flags & WHO_FLAGS) != (b->e_flags & WHO_FLAGS))
>> +		return 0;
>> +	return a->e_id == b->e_id;
>> +#undef WHO_FLAGS
>
> Ugh.
>
> ....


Will remove.


>
>> +#define richacl_for_each_entry(_ace, _acl) \
>> +	for (_ace = _acl->a_entries; \
>> +	     _ace != _acl->a_entries + _acl->a_count; \
>> +	     _ace++)
>> +
>> +#define richacl_for_each_entry_reverse(_ace, _acl) \
>> +	for (_ace = _acl->a_entries + _acl->a_count - 1; \
>> +	     _ace != _acl->a_entries - 1; \
>> +	     _ace--)
>
> somewhat lacking in ()...


Will add

>
>> +/* Flag values defined by rich-acl */
>> +#define ACL4_MASKED			0x80
>> +
>> +#define ACL4_VALID_FLAGS (			\
>> +		ACL4_MASKED)
>> +
>> +/* e_type values */
>> +#define ACE4_ACCESS_ALLOWED_ACE_TYPE	0x0000
>> +#define ACE4_ACCESS_DENIED_ACE_TYPE	0x0001
>> +/*#define ACE4_SYSTEM_AUDIT_ACE_TYPE	0x0002*/
>> +/*#define ACE4_SYSTEM_ALARM_ACE_TYPE	0x0003*/
>
> What's with all the commented out types?
>

These are NFSv4 ACL ACE types which we are not implementing. Just left
it there for documentation.

-aneesh

