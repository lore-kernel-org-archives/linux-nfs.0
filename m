From: Steve Dickson <SteveD@redhat.com>
Subject: Re: [PATCH 1/3] Remove redundant m_path field
Date: Thu, 28 Aug 2008 11:36:03 -0400
Message-ID: <48B6C5E3.3040508@RedHat.com>
References: <1218422830-5465-1-git-send-email-bfields@citi.umich.edu> <1218422830-5465-2-git-send-email-bfields@citi.umich.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-nfs@vger.kernel.org
To: Bruce Fields <bfields@citi.umich.edu>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:33169 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752957AbYH1PiM (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 28 Aug 2008 11:38:12 -0400
In-Reply-To: <1218422830-5465-2-git-send-email-bfields@citi.umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



Bruce Fields wrote:
> From: J. Bruce Fields <bfields@citi.umich.edu>
> 
> Contrary to the comment above its definition, the field m_path always
> has the same value as e_path: the *only* modifications of m_path are all
> of the form:
> 
> 	strncpy(exp->m_export.m_path, exp->m_export.e_path,
> 		sizeof (exp->m_export.m_path) - 1);
> 	exp->m_export.m_path[sizeof (exp->m_export.m_path) - 1] = '\0';
> 
> So m_path is always just a copy of e_path.  In places where we need to
> store a path to a submount of a CROSSMNT-exported filesystem, as in
> cache.c, we just use a local variable.
> 
> Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
Committed....

steved.
