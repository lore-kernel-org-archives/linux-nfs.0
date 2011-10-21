Return-Path: linux-nfs-owner@vger.kernel.org
Received: from e7.ny.us.ibm.com ([32.97.182.137]:50284 "EHLO e7.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754169Ab1JUNN4 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 21 Oct 2011 09:13:56 -0400
Received: from /spool/local
	by e7.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-nfs@vger.kernel.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Fri, 21 Oct 2011 09:13:54 -0400
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
To: Andreas Gruenbacher <agruen@kernel.org>
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
        Christoph Hellwig <hch@infradead.org>, akpm@linux-foundation.org,
        viro@zeniv.linux.org.uk, dhowells@redhat.com,
        linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org
Subject: Re: [PATCH -V7 21/26] richacl: xattr mapping functions
In-Reply-To: <1319194331.5930.9.camel@schurl.linbit>
References: <1318951981-5508-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com> <1318951981-5508-22-git-send-email-aneesh.kumar@linux.vnet.ibm.com> <20111019222021.GB1874@fieldses.org> <87k4805alx.fsf@linux.vnet.ibm.com> <20111020091434.GC5444@fieldses.org> <20111020091946.GA23773@infradead.org> <20111020102538.GG5444@fieldses.org> <1319154390.2270.52.camel@schurl.linbit> <874nz265tq.fsf@linux.vnet.ibm.com> <1319194331.5930.9.camel@schurl.linbit>
Date: Fri, 21 Oct 2011 18:42:50 +0530
Message-ID: <871uu65vzh.fsf@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 21 Oct 2011 12:52:10 +0200, Andreas Gruenbacher <agruen@kernel.org> wrote:
> On Fri, 2011-10-21 at 15:10 +0530, Aneesh Kumar K.V wrote:
> > How about the below change. This will require richacl tools change
> > also.
> 
> >  I made the e_flags 32 bit to make sure we don't take the space
> >  needed NFSv4 ACL related flags.
> 
> But struct richace_xattr has a hole now.  
> 
> There's ample of space left in the 16-bit field; I don't think there is
> a need to extend it.  If the need should ever arise, we can still define
> a new version of the xattr format.  Also, this change creates a hole in
> struct richace_xattr; we can't do that.
> 
> > +#define ACE4_SPECIAL_WHO		0x80000000
> > +#define ACE4_UNIXID_WHO			0x40000000
> 
> Can the ACE4_UNIXID_WHO flag please be removed again?  It isn't needed,
> it just creates a mess.
> 

Updated one below

diff --git a/fs/richacl_base.c b/fs/richacl_base.c
index 9a57039..fcc37d6 100644
--- a/fs/richacl_base.c
+++ b/fs/richacl_base.c
@@ -20,19 +20,6 @@
 
 MODULE_LICENSE("GPL");
 
-/*
- * Special e_who identifiers:  ACEs which have ACE4_SPECIAL_WHO set in
- * ace->e_flags use these constants in ace->u.e_who.
- *
- * For efficiency, we compare pointers instead of comparing strings.
- */
-const char richace_owner_who[]	  = "OWNER@";
-EXPORT_SYMBOL_GPL(richace_owner_who);
-const char richace_group_who[]	  = "GROUP@";
-EXPORT_SYMBOL_GPL(richace_group_who);
-const char richace_everyone_who[] = "EVERYONE@";
-EXPORT_SYMBOL_GPL(richace_everyone_who);
-
 /**
  * richacl_alloc  -  allocate a richacl
  * @count:	number of entries
@@ -194,38 +181,11 @@ richace_is_same_identifier(const struct richace *a, const struct richace *b)
 #define WHO_FLAGS (ACE4_SPECIAL_WHO | ACE4_IDENTIFIER_GROUP)
 	if ((a->e_flags & WHO_FLAGS) != (b->e_flags & WHO_FLAGS))
 		return 0;
-	if (a->e_flags & ACE4_SPECIAL_WHO)
-		return a->u.e_who == b->u.e_who;
-	else
-		return a->u.e_id == b->u.e_id;
+	return a->e_id == b->e_id;
 #undef WHO_FLAGS
 }
 
 /**
- * richacl_set_who  -  set a special who value
- * @ace:	acl entry
- * @who:	who value to use
- */
-int
-richace_set_who(struct richace *ace, const char *who)
-{
-	if (!strcmp(who, richace_owner_who))
-		who = richace_owner_who;
-	else if (!strcmp(who, richace_group_who))
-		who = richace_group_who;
-	else if (!strcmp(who, richace_everyone_who))
-		who = richace_everyone_who;
-	else
-		return -EINVAL;
-
-	ace->u.e_who = who;
-	ace->e_flags |= ACE4_SPECIAL_WHO;
-	ace->e_flags &= ~ACE4_IDENTIFIER_GROUP;
-	return 0;
-}
-EXPORT_SYMBOL_GPL(richace_set_who);
-
-/**
  * richacl_allowed_to_who  -  mask flags allowed to a specific who value
  *
  * Computes the mask values allowed to a specific who value, taking
@@ -446,10 +406,10 @@ richacl_permission(struct inode *inode, const struct richacl *acl,
 				continue;
 		} else if (richace_is_unix_id(ace)) {
 			if (ace->e_flags & ACE4_IDENTIFIER_GROUP) {
-				if (!in_group_p(ace->u.e_id))
+				if (!in_group_p(ace->e_id))
 					continue;
 			} else {
-				if (current_fsuid() != ace->u.e_id)
+				if (current_fsuid() != ace->e_id)
 					continue;
 			}
 		} else
diff --git a/fs/richacl_xattr.c b/fs/richacl_xattr.c
index 02a7986..31e33b5 100644
--- a/fs/richacl_xattr.c
+++ b/fs/richacl_xattr.c
@@ -58,19 +58,14 @@ richacl_from_xattr(const void *value, size_t size)
 		goto fail_einval;
 
 	richacl_for_each_entry(ace, acl) {
-		const char *who = (void *)(xattr_ace + 1), *end;
-		ssize_t used = (void *)who - value;
 
-		if (used > size)
-			goto fail_einval;
-		end = memchr(who, 0, size - used);
-		if (!end)
+		if (((void *)xattr_ace + sizeof(*xattr_ace)) > (value + size))
 			goto fail_einval;
 
-		ace->e_type = le16_to_cpu(xattr_ace->e_type);
+		ace->e_type  = le16_to_cpu(xattr_ace->e_type);
 		ace->e_flags = le16_to_cpu(xattr_ace->e_flags);
-		ace->e_mask = le32_to_cpu(xattr_ace->e_mask);
-		ace->u.e_id = le32_to_cpu(xattr_ace->e_id);
+		ace->e_mask  = le32_to_cpu(xattr_ace->e_mask);
+		ace->e_id    = le32_to_cpu(xattr_ace->e_id);
 
 		if (ace->e_flags & ~ACE4_VALID_FLAGS)
 			goto fail_einval;
@@ -78,13 +73,7 @@ richacl_from_xattr(const void *value, size_t size)
 		    (ace->e_mask & ~ACE4_VALID_MASK))
 			goto fail_einval;
 
-		if (who == end) {
-			if (ace->u.e_id == -1)
-				goto fail_einval;  /* uid/gid needed */
-		} else if (richace_set_who(ace, who))
-			goto fail_einval;
-
-		xattr_ace = (void *)who + ALIGN(end - who + 1, 4);
+		xattr_ace++;
 	}
 
 	return acl;
@@ -102,13 +91,8 @@ size_t
 richacl_xattr_size(const struct richacl *acl)
 {
 	size_t size = sizeof(struct richacl_xattr);
-	const struct richace *ace;
 
-	richacl_for_each_entry(ace, acl) {
-		size += sizeof(struct richace_xattr) +
-			(richace_is_unix_id(ace) ? 4 :
-			 ALIGN(strlen(ace->u.e_who) + 1, 4));
-	}
+	size += sizeof(struct richace_xattr) * acl->a_count;
 	return size;
 }
 EXPORT_SYMBOL_GPL(richacl_xattr_size);
@@ -139,18 +123,8 @@ richacl_to_xattr(const struct richacl *acl, void *buffer)
 		xattr_ace->e_flags = cpu_to_le16(ace->e_flags &
 						 ACE4_VALID_FLAGS);
 		xattr_ace->e_mask = cpu_to_le32(ace->e_mask);
-		if (richace_is_unix_id(ace)) {
-			xattr_ace->e_id = cpu_to_le32(ace->u.e_id);
-			memset(xattr_ace->e_who, 0, 4);
-			xattr_ace = (void *)xattr_ace->e_who + 4;
-		} else {
-			int sz = ALIGN(strlen(ace->u.e_who) + 1, 4);
-
-			xattr_ace->e_id = cpu_to_le32(-1);
-			memset(xattr_ace->e_who + sz - 4, 0, 4);
-			strcpy(xattr_ace->e_who, ace->u.e_who);
-			xattr_ace = (void *)xattr_ace->e_who + sz;
-		}
+		xattr_ace->e_id = cpu_to_le32(ace->e_id);
+		xattr_ace++;
 	}
 }
 EXPORT_SYMBOL_GPL(richacl_to_xattr);
diff --git a/include/linux/richacl.h b/include/linux/richacl.h
index 4af6d22..3fc6be2 100644
--- a/include/linux/richacl.h
+++ b/include/linux/richacl.h
@@ -17,14 +17,15 @@
 #define __RICHACL_H
 #include <linux/slab.h>
 
+#define ACE_OWNER_ID		130
+#define ACE_GROUP_ID		131
+#define ACE_EVERYONE_ID		110
+
 struct richace {
 	unsigned short	e_type;
 	unsigned short	e_flags;
 	unsigned int	e_mask;
-	union {
-		unsigned int	e_id;
-		const char	*e_who;
-	} u;
+	unsigned int	e_id;
 };
 
 struct richacl {
@@ -74,7 +75,7 @@ struct richacl {
 /*#define ACE4_FAILED_ACCESS_ACE_FLAG	0x0020*/
 #define ACE4_IDENTIFIER_GROUP		0x0040
 #define ACE4_INHERITED_ACE		0x0080
-/* in-memory representation only */
+/* richacl specific flag values */
 #define ACE4_SPECIAL_WHO		0x4000
 
 #define ACE4_VALID_FLAGS (			\
@@ -83,7 +84,9 @@ struct richacl {
 	ACE4_NO_PROPAGATE_INHERIT_ACE |		\
 	ACE4_INHERIT_ONLY_ACE |			\
 	ACE4_IDENTIFIER_GROUP |			\
-	ACE4_INHERITED_ACE)
+	ACE4_INHERITED_ACE |			\
+	ACE4_SPECIAL_WHO)
+
 
 /* e_mask bitflags */
 #define ACE4_READ_DATA			0x00000001
@@ -254,14 +257,6 @@ richacl_is_protected(const struct richacl *acl)
 	return acl->a_flags & ACL4_PROTECTED;
 }
 
-/*
- * Special e_who identifiers: we use these pointer values in comparisons
- * instead of doing a strcmp.
- */
-extern const char richace_owner_who[];
-extern const char richace_group_who[];
-extern const char richace_everyone_who[];
-
 /**
  * richace_is_owner  -  check if @ace is an OWNER@ entry
  */
@@ -269,7 +264,7 @@ static inline int
 richace_is_owner(const struct richace *ace)
 {
 	return (ace->e_flags & ACE4_SPECIAL_WHO) &&
-	       ace->u.e_who == richace_owner_who;
+	       ace->e_id == ACE_OWNER_ID;
 }
 
 /**
@@ -279,7 +274,7 @@ static inline int
 richace_is_group(const struct richace *ace)
 {
 	return (ace->e_flags & ACE4_SPECIAL_WHO) &&
-	       ace->u.e_who == richace_group_who;
+	       ace->e_id == ACE_GROUP_ID;
 }
 
 /**
@@ -289,7 +284,7 @@ static inline int
 richace_is_everyone(const struct richace *ace)
 {
 	return (ace->e_flags & ACE4_SPECIAL_WHO) &&
-	       ace->u.e_who == richace_everyone_who;
+	       ace->e_id == ACE_EVERYONE_ID;
 }
 
 /**
@@ -357,7 +352,6 @@ richace_is_deny(const struct richace *ace)
 extern struct richacl *richacl_alloc(int);
 extern int richace_is_same_identifier(const struct richace *,
 				      const struct richace *);
-extern int richace_set_who(struct richace *, const char *);
 extern int richacl_masks_to_mode(const struct richacl *);
 extern unsigned int richacl_mode_to_mask(mode_t);
 extern unsigned int richacl_want_to_mask(unsigned int);
diff --git a/include/linux/richacl_xattr.h b/include/linux/richacl_xattr.h
index f79ec12..792abcc 100644
--- a/include/linux/richacl_xattr.h
+++ b/include/linux/richacl_xattr.h
@@ -25,7 +25,6 @@ struct richace_xattr {
 	__le16		e_flags;
 	__le32		e_mask;
 	__le32		e_id;
-	char		e_who[0];
 };
 
 struct richacl_xattr {

