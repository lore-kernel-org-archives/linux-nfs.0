From: Arjan van de Ven <arjan@linux.intel.com>
Subject: Re: PATCH 2 of 4] cpumask: export cpu_online_map and cpu_possible_map
 consistently
Date: Fri, 04 Aug 2006 07:45:45 -0700
Message-ID: <44D35D99.601@linux.intel.com>
References: <1154669759.21040.2353.camel@hole.melbourne.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: Andrew Morton <akpm@osdl.org>, Neil Brown <neilb@suse.de>,
	Linux NFS Mailing List <nfs@lists.sourceforge.net>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1161237AbWHDOqF@vger.kernel.org>
To: Greg Banks <gnb@melbourne.sgi.com>
In-Reply-To: <1154669759.21040.2353.camel@hole.melbourne.sgi.com>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

Greg Banks wrote:
> cpumask: ensure that the cpu_online_map and cpu_possible_map bitmasks,
> and hence all the macros in <linux/cpumask.h> that require them, are
> available to modules for all supported combinations of architecture
> and CONFIG_SMP.

Are there any actual users of this?
