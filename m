From: NeilBrown <neilb@suse.de>
Subject: [PATCH 000 of 20] knfsd: Support 'secinfo' exports with related cleanups
Date: Tue, 10 Jul 2007 12:22:37 +1000
Message-ID: <20070710121949.12548.patches@notabene>
Cc: nfs@lists.sourceforge.net, linux-kernel@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1762668AbXGJC1t@vger.kernel.org>
Cc: andros "@" citi "." umich "." edu <andros@citi.umich.edu>
Cc: Andy Adamson <andros@citi.umich.edu>
Cc: "J. Bruce Fields" <bfields@citi.umich.edu>
Cc: J "." Bruce Fields <bfields@citi.umich.edu>
Cc: J "." Bruce Fields <bfields@puzzle.fieldses.org>
Cc: Neil Brown <neilb@suse.de>
Cc: Usha Ketineni <ketineni@us.ibm.com>
Cc: Usha Ketineni <uketinen@us.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

With this patchset it becomes possible to list a number of different
security flavours that maybe used to access an exported filesystem,
and to attach different export options (e.g. readonly, rootsquash) to
different flavours.
Also, NFSv4 can report which flavours are available on a particular export.

They are suitable for 2.6.23.

NeilBrown



 [PATCH 001 of 20] knfsd: nfsd: make all exp_finding functions return -errno's on err
 [PATCH 002 of 20] knfsd: nfsd4: build rpcsec_gss whenever nfsd4 is built
 [PATCH 003 of 20] knfsd: nfsd4: store pseudoflavor in request
 [PATCH 004 of 20] knfsd: nfsd4: parse secinfo information in exports downcall
 [PATCH 005 of 20] knfsd: nfsd4: simplify exp_pseudoroot arguments
 [PATCH 006 of 20] knfsd: nfsd: remove superfluous assignment from nfsd_lookup
 [PATCH 007 of 20] knfsd: nfsd: provide export lookup wrappers which take a svc_rqst
 [PATCH 008 of 20] knfsd: nfsd: set rq_client to ip-address-determined-domain
 [PATCH 009 of 20] knfsd: nfsd: use ip-address-based domain in secinfo case
 [PATCH 010 of 20] knfsd: nfsd: factor nfsd_lookup into 2 pieces
 [PATCH 011 of 20] knfsd: nfsd4: return nfserr_wrongsec
 [PATCH 012 of 20] knfsd: nfsd4: make readonly access depend on pseudoflavor
 [PATCH 013 of 20] knfsd: nfsd: factor out code from show_expflags
 [PATCH 014 of 20] knfsd: nfsd: display export secinfo information
 [PATCH 015 of 20] knfsd: nfsd4: make readonly access depend on pseudoflavor
 [PATCH 016 of 20] knfsd: rpc: add gss krb5 and spkm3 oid values
 [PATCH 017 of 20] knfsd: nfsd4: implement secinfo
 [PATCH 018 of 20] knfsd: nfsd4: secinfo handling without secinfo= option
 [PATCH 019 of 20] knfsd: nfsd: allow auth_sys nlm on rpcsec_gss exports
 [PATCH 020 of 20] knfsd: nfsd: enforce per-flavor id squashing
