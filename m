Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:5069 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755694Ab1KNSCv (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 14 Nov 2011 13:02:51 -0500
Message-ID: <4EC157C6.7030308@RedHat.com>
Date: Mon, 14 Nov 2011 13:02:46 -0500
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: Jim Rees <rees@umich.edu>
CC: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] rpc.idmapd: Sections in idmapd.conf are ignored.
References: <1321283020-15730-1-git-send-email-steved@redhat.com> <20111114174450.GA16366@umich.edu>
In-Reply-To: <20111114174450.GA16366@umich.edu>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 11/14/2011 12:44 PM, Jim Rees wrote:
> Steve Dickson wrote:
> 
>   In the parsing routine, conf_parse_line(), a string
>   is not being null terminated which is causing
>   section of the config file to be ignored.
>   
>   https://bugzilla.linux-nfs.org/show_bug.cgi?id=205
>   
>   Signed-off-by: Steve Dickson <steved@redhat.com>
>   ---
>    support/nfs/conffile.c |    3 ++-
>    1 files changed, 2 insertions(+), 1 deletions(-)
>   
>   diff --git a/support/nfs/conffile.c b/support/nfs/conffile.c
>   index fa0dc6b..3990578 100644
>   --- a/support/nfs/conffile.c
>   +++ b/support/nfs/conffile.c
>   @@ -256,13 +256,14 @@ conf_parse_line(int trans, char *line, size_t sz)
>    			val++, j++;
>    		if (*val)
>    			i = j;
>   -		section = malloc(i);
>   +		section = malloc(i+1);
>    		if (!section) {
>    			xlog_warn("conf_parse_line: %d: malloc (%lu) failed", ln,
>    						(unsigned long)i);
>    			return;
>    		}
>    		strncpy(section, line, i);
>   +		section[i] = '\0';
>    
>    		if (arg) 
>    			free(arg);
> 
> Use of strdup() would not only make the code simpler but would eliminate the
> possibility of introducing this kind of bug.
I thought of that... but from my reading of the code
the entire string is not wanted, just a section of
the string is needed...  

thanks!

steved.

