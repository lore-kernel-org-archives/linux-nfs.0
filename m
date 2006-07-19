From: Mario Fetka <mario-fetka@gmx.at>
Subject: Re: Heimdal compile error
Date: Wed, 19 Jul 2006 15:50:31 +0200
Message-ID: <200607191550.32050.mario-fetka@gmx.at>
References: <200607171049.31126.mario-fetka@gmx.at>
	<200607171056.01407.mario-fetka@gmx.at>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1G3CRl-0004Aa-2a
	for nfs@lists.sourceforge.net; Wed, 19 Jul 2006 06:50:41 -0700
Received: from mail.gmx.de ([213.165.64.21] helo=mail.gmx.net)
	by mail.sourceforge.net with smtp (Exim 4.44) id 1G3CRk-0006RZ-RM
	for nfs@lists.sourceforge.net; Wed, 19 Jul 2006 06:50:41 -0700
To: nfs@lists.sourceforge.net
In-Reply-To: <200607171056.01407.mario-fetka@gmx.at>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

Am Montag, 17. Juli 2006 10:56 schrieb Mario Fetka:
> i forgot the error:
>
> if
> i686-pc-linux-gnu-gcc -DHAVE_CONFIG_H -I. -I. -I../../support/include 
> -I../../support/include -D_FILE_OFFSET_BITS=64 -D_GNU_SOURCE -Wall  -pipe
> -O2 -pipe -march=pentium-m -fomit-frame-pointer -mfpmath=sse
> -I/usr/include/rpcsecgss -I/usr/include/gssglue   -I/usr/include/heimdal
> -I/usr/athena/include -O2 -pipe -march=pentium-m -fomit-frame-pointer
> -mfpmath=sse -MT gssd-context_heimdal.o -MD -MP -MF
> ".deps/gssd-context_heimdal.Tpo" -c -o gssd-context_heimdal.o `test -f
> 'context_heimdal.c' ||
> echo './'`context_heimdal.c; \
>         then
> mv -f ".deps/gssd-context_heimdal.Tpo" ".deps/gssd-context_heimdal.Po";
> else rm -f ".deps/gssd-context_heimdal.Tpo"; exit 1; fi
> context_heimdal.c: In function 'write_heimdal_enc_key':
> context_heimdal.c:81: error: dereferencing pointer to incomplete type
> context_heimdal.c: In function 'write_heimdal_seq_key':
> context_heimdal.c:139: error: dereferencing pointer to incomplete type
> context_heimdal.c: In function 'serialize_krb5_ctx':
> context_heimdal.c:218: error: dereferencing pointer to incomplete type
> context_heimdal.c:218: error: 'LOCAL' undeclared (first use in this
> function) context_heimdal.c:218: error: (Each undeclared identifier is
> reported only once
> context_heimdal.c:218: error: for each function it appears in.)
> context_heimdal.c:241: error: dereferencing pointer to incomplete type
> context_heimdal.c:241: error: dereferencing pointer to incomplete type
> context_heimdal.c:244: error: dereferencing pointer to incomplete type
> context_heimdal.c:244: error: dereferencing pointer to incomplete type
> context_heimdal.c:247: warning: dereferencing type-punned pointer will
> break strict-aliasing rules
> make[2]: *** [gssd-context_heimdal.o] Error 1
> make[2]: Leaving directory
> `/var/tmp/portage/nfs-utils-1.0.9/work/nfs-utils-1.0.9/utils/gssd'
> make[1]: *** [all-recursive] Error 1
> make[1]: Leaving directory
> `/var/tmp/portage/nfs-utils-1.0.9/work/nfs-utils-1.0.9/utils'
> make: *** [all-recursive] Error 1
>
> Am Montag, 17. Juli 2006 10:49 schrieb Mario Fetka:
> > the following patch corrects the error.
> >
> > diff -urN nfs-utils-1.0.7.org/utils/gssd/context_heimdal.c
> > nfs-utils-1.0.7/utils/gssd/context_heimdal.c
> > --- nfs-utils-1.0.7.org/utils/gssd/context_heimdal.c    2005-07-10
> > 12:14:01.526867000 +0200
> > +++ nfs-utils-1.0.7/utils/gssd/context_heimdal.c        2005-07-10
> > 12:14:32.815110736 +0200
> > @@ -46,6 +46,20 @@
> >  #include "gss_oids.h"
> >  #include "write_bytes.h"
> >
> > +typedef struct gss_ctx_id_t_desc_struct {
> > +  struct krb5_auth_context_data *auth_context;
> > +  gss_name_t source, target;
> > +  OM_uint32 flags;
> > +  enum { LOCAL = 1, OPEN = 2,
> > +         COMPAT_OLD_DES3 = 4,
> > +         COMPAT_OLD_DES3_SELECTED = 8,
> > +  } more_flags;
> > +  struct krb5_ticket *ticket;
> > +  OM_uint32 lifetime;
> > +  pthread_mutex_t ctx_id_mutex;
> > +  struct gss_msg_order *order;
> > +} gss_ctx_id_t_desc;
> > +
> >  #define MAX_CTX_LEN 4096
> >
> >  int write_heimdal_keyblock(char **p, char *end, krb5_keyblock *key)
> >
> > wfg
> > Mario
> >
this patch adds an internal only struct (starting with 0.7 internal only) to 
nfs-utils..

i am not skilled enought to do the fix in the right way. 
could someone plz help

wfg
Mario

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys -- and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
