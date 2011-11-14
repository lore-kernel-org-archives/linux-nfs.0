Return-Path: linux-nfs-owner@vger.kernel.org
Received: from smtp.mail.umich.edu ([141.211.12.86]:33099 "EHLO
	tombraider.mr.itd.umich.edu" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751410Ab1KNRoz (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 14 Nov 2011 12:44:55 -0500
Date: Mon, 14 Nov 2011 12:44:50 -0500
From: Jim Rees <rees@umich.edu>
To: Steve Dickson <steved@redhat.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] rpc.idmapd: Sections in idmapd.conf are ignored.
Message-ID: <20111114174450.GA16366@umich.edu>
References: <1321283020-15730-1-git-send-email-steved@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1321283020-15730-1-git-send-email-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Steve Dickson wrote:

  In the parsing routine, conf_parse_line(), a string
  is not being null terminated which is causing
  section of the config file to be ignored.
  
  https://bugzilla.linux-nfs.org/show_bug.cgi?id=205
  
  Signed-off-by: Steve Dickson <steved@redhat.com>
  ---
   support/nfs/conffile.c |    3 ++-
   1 files changed, 2 insertions(+), 1 deletions(-)
  
  diff --git a/support/nfs/conffile.c b/support/nfs/conffile.c
  index fa0dc6b..3990578 100644
  --- a/support/nfs/conffile.c
  +++ b/support/nfs/conffile.c
  @@ -256,13 +256,14 @@ conf_parse_line(int trans, char *line, size_t sz)
   			val++, j++;
   		if (*val)
   			i = j;
  -		section = malloc(i);
  +		section = malloc(i+1);
   		if (!section) {
   			xlog_warn("conf_parse_line: %d: malloc (%lu) failed", ln,
   						(unsigned long)i);
   			return;
   		}
   		strncpy(section, line, i);
  +		section[i] = '\0';
   
   		if (arg) 
   			free(arg);

Use of strdup() would not only make the code simpler but would eliminate the
possibility of introducing this kind of bug.
