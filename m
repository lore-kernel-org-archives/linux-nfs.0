Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail1.bemta5.messagelabs.com ([195.245.231.144]:31592 "EHLO
	mail1.bemta5.messagelabs.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752993AbaJ3Iwu convert rfc822-to-8bit
	(ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 30 Oct 2014 04:52:50 -0400
From: =?iso-8859-1?Q?Erik_S=F8rnes?= <Erik.Sornes@nilu.no>
To: "bfields@redhat.com" <bfields@redhat.com>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: RE: feature / patch
Date: Thu, 30 Oct 2014 08:46:01 +0000
Message-ID: <9B915D2BFADBEB47B10A252C42BF68E241B9E33B@NILU-MAIL1.nilu.local>
References: <9B915D2BFADBEB47B10A252C42BF68E241B8F984@NILU-MAIL1.nilu.local>,<20141027210402.GB20946@pad.redhat.com>,<9B915D2BFADBEB47B10A252C42BF68E241B90659@NILU-MAIL1.nilu.local>
In-Reply-To: <9B915D2BFADBEB47B10A252C42BF68E241B90659@NILU-MAIL1.nilu.local>
Content-Type: text/plain; charset=US-ASCII
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi,
>>
>> Hi!
>>
>> I'm thinking about a patch for nfs4_acl_tools to be able to add an ACE only if it is not already present in the ACL.
>>
>> I'm thinking about maybe an "-u" (u for unique) -switch.
>>
>Sounds like a sensible request, sure.
>

Have  written a little patch to implement the "unique"-functionality.
I have expanded the  the nfs4_insert_file_aces and nfs4_insert_string_aces functions to include another parameter, which I have called "add_condition".
(Maybe for other add_conditions in the future, like "merge" or maybe "logical add" ace' s for a user or group)
Maybe I should have used separate functions and created files like  nfs4_insert_file_aces_unique.c nfs4_insert_string_aces_unique.c instead ?
The way I have done it looks like the best way to reuse code for me.
The patch, which is made with git diff,  compiles without errors and seams to work ok on our production system.

Do you like it ?

regards
Erik


diff --git a/include/libacl_nfs4.h b/include/libacl_nfs4.h
index 2f7cc28..0e4e74d 100644
--- a/include/libacl_nfs4.h
+++ b/include/libacl_nfs4.h
@@ -156,6 +156,8 @@ enum {      ACL_NFS4_NOT_USED = 0,
                ACL_NFS4_USED
 };

+enum { ACE_NOT_UNIQUE, ACE_UNIQUE } add_condition;
+
 struct ace_container {
        struct nfs4_ace *ace;
        TAILQ_ENTRY(ace_container) l_ace;
@@ -182,8 +184,8 @@ extern int                  nfs4_insert_ace_at(struct nfs4_acl *acl, struct nfs4_ace *ace, unsi
 extern struct nfs4_ace *       nfs4_new_ace(int is_directory, u32 type, u32 flag, u32 access_mask, int whotype, char* who);
 extern struct nfs4_acl *       nfs4_new_acl(u32);

-extern int                     nfs4_insert_file_aces(struct nfs4_acl *acl, FILE* fd, unsigned int index);
-extern int                     nfs4_insert_string_aces(struct nfs4_acl *acl, const char *acl_spec, unsigned int index);
+extern int                     nfs4_insert_file_aces(struct nfs4_acl *acl, FILE* fd, unsigned int index, int add_condition);
+extern int                     nfs4_insert_string_aces(struct nfs4_acl *acl, const char *acl_spec, unsigned int index, int add_condition);
 extern int                     nfs4_replace_ace(struct nfs4_acl *acl, struct nfs4_ace *old_ace, struct nfs4_ace *new_ace);
 extern int                     nfs4_replace_ace_spec(struct nfs4_acl *acl, char *from_ace_spec, char *to_ace_spec);
 extern int                     nfs4_remove_file_aces(struct nfs4_acl *acl, FILE *fd);
@@ -194,7 +196,7 @@ extern int                  nfs4_remove_string_aces(struct nfs4_acl *acl, char *string);
 extern struct nfs4_ace *       nfs4_ace_from_string(char *ace_spec, int is_dir);
 extern struct nfs4_acl *       nfs4_acl_for_path(const char *path);
 extern char *                  nfs4_acl_spec_from_file(FILE *f);
-
+extern int                     nfs4_ace_is_in_acl(struct nfs4_acl *acl, struct nfs4_ace *ace);

 /** Access Functions **/
 extern int                     acl_nfs4_get_who(struct nfs4_ace*, int*, char**);
diff --git a/libnfs4acl/nfs4_acl_utils.c b/libnfs4acl/nfs4_acl_utils.c
index ae476e6..820a896 100644
--- a/libnfs4acl/nfs4_acl_utils.c
+++ b/libnfs4acl/nfs4_acl_utils.c
@@ -172,3 +172,28 @@ int nfs4_ace_cmp(struct nfs4_ace *lhs, struct nfs4_ace *rhs)
                return 0;
        return 1;
 }
+
+/*
+ * returns 0 if acl contains ace
+ * returns -2 (-ENOENT) if ace not found in acl
+ */
+
+int nfs4_ace_is_in_acl(struct nfs4_acl *acl, struct nfs4_ace *ace)
+{
+       struct nfs4_ace *existing_ace;
+       int err = -2;
+
+       if (acl == NULL || acl->naces == 0)
+               goto out;
+       if (ace == NULL )
+               goto out;
+
+       for (existing_ace = nfs4_get_first_ace(acl); existing_ace != NULL; existing_ace = nfs4_get_next_ace(&existing_ace))
+               if (!nfs4_ace_cmp(existing_ace, ace)) {
+                       err = 0;
+                       break;
+               }
+out:
+       return err;
+}
+
diff --git a/libnfs4acl/nfs4_insert_file_aces.c b/libnfs4acl/nfs4_insert_file_aces.c
index e8b3582..98237ea 100644
--- a/libnfs4acl/nfs4_insert_file_aces.c
+++ b/libnfs4acl/nfs4_insert_file_aces.c
@@ -44,11 +44,11 @@
  * output
  *     0 on success OR -1 on error.
  */
-int nfs4_insert_file_aces(struct nfs4_acl *acl, FILE* fp, unsigned int index)
+int nfs4_insert_file_aces(struct nfs4_acl *acl, FILE* fp, unsigned int index, int add_condition)
 {
        char *acl_spec;

        if ((acl_spec = nfs4_acl_spec_from_file(fp)) == NULL)
                return -1;
-       return nfs4_insert_string_aces(acl, acl_spec, index);
+       return nfs4_insert_string_aces(acl, acl_spec, index, add_condition);
 }
diff --git a/libnfs4acl/nfs4_insert_string_aces.c b/libnfs4acl/nfs4_insert_string_aces.c
index 5a482d5..d0eee32 100644
--- a/libnfs4acl/nfs4_insert_string_aces.c
+++ b/libnfs4acl/nfs4_insert_string_aces.c
@@ -36,7 +36,7 @@
  * nfs4_insert_string_aces - read ACE entries from spec string into struct nfs4_acl
  */

-int nfs4_insert_string_aces(struct nfs4_acl *acl, const char *acl_spec, unsigned int index)
+int nfs4_insert_string_aces(struct nfs4_acl *acl, const char *acl_spec, unsigned int index, int add_condition)
 {
        char *s, *sp, *ssp;
        struct nfs4_ace *ace;
@@ -51,11 +51,19 @@ int nfs4_insert_string_aces(struct nfs4_acl *acl, const char *acl_spec, unsigned

                if ((ace = nfs4_ace_from_string(ssp, acl->is_directory)) == NULL)
                        goto out_failed;
+               /* ace is added wether it is already present or not */
+               if ( add_condition == ACE_NOT_UNIQUE )
+                       if (nfs4_insert_ace_at(acl, ace, index++)) {
+                               free(ace);
+                               goto out_failed;
+                       }
+               /* ace is only added if it is not already present */
+               if ( add_condition == ACE_UNIQUE && nfs4_ace_is_in_acl(acl, ace) == -2 )
+                        if (nfs4_insert_ace_at(acl, ace, index++)) {
+                                free(ace);
+                                goto out_failed;
+                        }

-               if (nfs4_insert_ace_at(acl, ace, index++)) {
-                       free(ace);
-                       goto out_failed;
-               }
        }
        if (acl->naces == 0)
                goto out_failed;
diff --git a/libnfs4acl/nfs4_remove_string_aces.c b/libnfs4acl/nfs4_remove_string_aces.c
index ff241d9..97a1624 100644
--- a/libnfs4acl/nfs4_remove_string_aces.c
+++ b/libnfs4acl/nfs4_remove_string_aces.c
@@ -44,7 +44,7 @@ int nfs4_remove_string_aces(struct nfs4_acl *acl, char *acl_spec)
        if ((anti_acl = nfs4_new_acl(acl->is_directory)) == NULL)
                goto out;

-       if (nfs4_insert_string_aces(anti_acl, acl_spec, 0))
+       if (nfs4_insert_string_aces(anti_acl, acl_spec, 0, 0))
                goto out;

        for (anti_ace = nfs4_get_first_ace(anti_acl); anti_ace != NULL; anti_ace = nfs4_get_next_ace(&anti_ace))
diff --git a/man/man1/nfs4_setfacl.1 b/man/man1/nfs4_setfacl.1
index a316bf2..25661e2 100644
--- a/man/man1/nfs4_setfacl.1
+++ b/man/man1/nfs4_setfacl.1
@@ -101,6 +101,9 @@ in conjunction with
 in conjunction with
 .BR -R / --recursive ", a physical walk skips all symbolic links."
 .TP
+.BR "-u" , " --unique"
+avoids adding duplicate ace's if they are already present.
+.TP
 .BR --test
 display results of
 .BR COMMAND ,
diff --git a/nfs4_setfacl/nfs4_setfacl.c b/nfs4_setfacl/nfs4_setfacl.c
index a958ac1..efa5741 100644
--- a/nfs4_setfacl/nfs4_setfacl.c
+++ b/nfs4_setfacl/nfs4_setfacl.c
@@ -98,6 +98,7 @@ static struct option long_options[] = {
        { "edit",               0, 0, 'e' },
        { "test",               0, 0, 't' },
        { "help",               0, 0, 'h' },
+       { "unique",             0, 0, 'u' },
        { "version",            0, 0, 'v' },
        { "more-help",          0, 0, 'H' },
        { "recursive",          0, 0, 'R' },
@@ -130,6 +131,7 @@ int main(int argc, char **argv)
        int numpaths = 0, curpath = 0;
        char *tmp, **paths = NULL, *path = NULL, *spec_file = NULL;
        FILE *s_fp = NULL;
+       add_condition = ACE_NOT_UNIQUE;

        if (!strcmp(basename(argv[0]), "nfs4_editfacl")) {
                action = EDIT_ACTION;
@@ -141,7 +143,7 @@ int main(int argc, char **argv)
                return err;
        }

-       while ((opt = getopt_long(argc, argv, "-:a:A:s:S:x:X:m:ethvHRPL", long_options, NULL)) != -1) {
+       while ((opt = getopt_long(argc, argv, "-:a:A:s:S:x:X:m:ethvuHRPL", long_options, NULL)) != -1) {
                switch (opt) {
                        case 'a':
                                mod_string = optarg;
@@ -208,6 +210,10 @@ int main(int argc, char **argv)
                                is_test = 1;
                                break;

+                        case 'u':
+                                add_condition = ACE_UNIQUE;
+                                break;
+
                        case 'R':
                                do_recursive = YES_RECURSIVE;
                                break;
@@ -233,7 +239,6 @@ int main(int argc, char **argv)
                        case 'v':
                                printf("%s %s\n", basename(argv[0]), VERSION);
                                return 0;
-
                        case ':':
                                /* missing argument */
                                switch (optopt) {
@@ -383,7 +388,7 @@ static int do_apply_action(const char *path, const struct stat *_st)
                /* default to prepending */
                if (ace_index < 1)
                        ace_index = 1;
-               if (nfs4_insert_string_aces(acl, mod_string, (ace_index - 1))) {
+               if (nfs4_insert_string_aces(acl, mod_string, (ace_index - 1), add_condition)) {
                        fprintf(stderr, "Failed while inserting ACE(s) (at index %d).\n", ace_index);
                        goto failed;
                }
@@ -414,7 +419,7 @@ static int do_apply_action(const char *path, const struct stat *_st)
                break;

        case SUBSTITUTE_ACTION:
-               if (nfs4_insert_string_aces(acl, mod_string, 0)) {
+               if (nfs4_insert_string_aces(acl, mod_string, 0, 0)) {
                        fprintf(stderr, "Failed while inserting ACE(s).\n");
                        goto failed;
                }
@@ -474,7 +479,7 @@ static struct nfs4_acl* edit_ACL(struct nfs4_acl *acl, const char *path, const s
        }
        if (open_editor(tmp_name))
                goto failed;
-       if (nfs4_insert_file_aces(newacl, tmp_fp, 0)) {
+       if (nfs4_insert_file_aces(newacl, tmp_fp, 0, add_condition)) {
                fprintf(stderr, "Failed loading ACL from edit tempfile %s. Aborting.\n", tmp_name);
                goto failed;
        }
@@ -556,6 +561,7 @@ static void __usage(const char *name, int is_ef)
        "   -R, --recursive      recursively apply to all files and directories\n"
        "   -L, --logical        logical walk, follow symbolic links\n"
        "   -P, --physical       physical walk, do not follow symbolic links\n"
+       "   -u, --unique                 only add ace's when they are unique in acl\n"
        "   --test               print resulting ACL, do not save changes\n"
        "\n"
        "     NOTE: if \"-\" is given with -A/-X/-S, entries will be read from stdin.\n\n";
P Please consider the environment before printing this email and attachments
