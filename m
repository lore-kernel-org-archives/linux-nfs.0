Received: from relay.hostedemail.com (smtprelay0011.hostedemail.com [216.40.44.11])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 7A8BE126C03;
	Sun, 21 Jun 2026 14:21:54 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=216.40.44.11
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1782051716; cv=none; b=FRRAI6pgbHBRNvPJ4gSq5TI7ENUHz5kkZbQXh741XGtp1NzalyIBKN0qGYbNArsTZiyetvFHDyMSx8/u+Myu0ECR3Qqfe9J7nSjrHErytEqtLcs61YVXkPPIkKxj3JlHFIv+CZItyJdG4K2BcyLzZlCrX9xabssDjF/hTrKXWjE=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1782051716; c=relaxed/simple;
	bh=IpwTUV7cMr9DZyt+PGfboKuTJxbESBW6N7Y5Sf43YLI=;
	h=Date:From:To:CC:Subject:In-Reply-To:References:Message-ID:
	 MIME-Version:Content-Type; b=YbP495Sol6A0VrKRNrzUV2NjE2F/YlU4yz8ki46SdAI01wVhFzvBf3eEzorQzjJE03Eal/n344XNfebREJDZtvr22DWL9u/6XnoG5IZpuLOn+0aqZEELz2fQlaHSA2DlwWeA2xU0IsuUBNZPDrsQzuXNhFvFyjMYGsP2iSlgLE0=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=goodmis.org; spf=pass smtp.mailfrom=goodmis.org; arc=none smtp.client-ip=216.40.44.11
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=goodmis.org
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=goodmis.org
Received: from omf19.hostedemail.com (lb01a-stub [10.200.18.249])
	by unirelay07.hostedemail.com (Postfix) with ESMTP id 36393166CE4;
	Sun, 21 Jun 2026 14:21:51 +0000 (UTC)
Received: from [HIDDEN] (Authenticated sender: rostedt@goodmis.org) by omf19.hostedemail.com (Postfix) with ESMTPA id 1169420026;
	Sun, 21 Jun 2026 14:21:46 +0000 (UTC)
Date: Sun, 21 Jun 2026 14:24:07 +0100
From: Steven Rostedt <rostedt@goodmis.org>
To: Yury Norov <yury.norov@gmail.com>, Steven Rostedt <rostedt@kernel.org>
CC: linux-kernel@vger.kernel.org, linux-trace-kernel@vger.kernel.org,
 Masami Hiramatsu <mhiramat@kernel.org>, Mark Rutland <mark.rutland@arm.com>,
 Mathieu Desnoyers <mathieu.desnoyers@efficios.com>,
 Andrew Morton <akpm@linux-foundation.org>,
 Linus Torvalds <torvalds@linux-foundation.org>,
 Sebastian Andrzej Siewior <bigeasy@linutronix.de>,
 John Ogness <john.ogness@linutronix.de>, Thomas Gleixner <tglx@kernel.org>,
 Peter Zijlstra <peterz@infradead.org>, Julia Lawall <julia.lawall@inria.fr>,
 linux-doc@vger.kernel.org, linux-kbuild@vger.kernel.org,
 linuxppc-dev@lists.ozlabs.org, dri-devel@lists.freedesktop.org,
 linux-stm32@st-md-mailman.stormreply.com,
 linux-arm-kernel@lists.infradead.org, linux-rdma@vger.kernel.org,
 linux-usb@vger.kernel.org, linux-ext4@vger.kernel.org,
 linux-nfs@vger.kernel.org, kvm@vger.kernel.org,
 intel-gfx@lists.freedesktop.org
Subject: =?US-ASCII?Q?Re=3A_=5BPATCH_1/2=5D_tracing=3A_Move_non-tra?=
 =?US-ASCII?Q?ce=5Fprintk_prototypes_back_to_kernel=2Eh?=
User-Agent: K-9 Mail for Android
In-Reply-To: <ajfiVTlCIVlqW3sh@yury>
References: <20260621093430.264983361@kernel.org> <20260621093811.007634476@kernel.org> <ajfiVTlCIVlqW3sh@yury>
Message-ID: <C4ED8F5F-042B-43B6-B17A-7C3E2743E48F@goodmis.org>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain;
 charset=utf-8
Content-Transfer-Encoding: quoted-printable
X-Stat-Signature: m5id8uysanmtioempn6emsnsdgs5phht
X-Rspamd-Server: rspamout02
X-Rspamd-Queue-Id: 1169420026
X-Session-Marker: 726F737465647440676F6F646D69732E6F7267
X-Session-ID: U2FsdGVkX19WinE5LWQa8HzvFNjRdlGwYann5/w38N8=
X-HE-Tag: 1782051706-894210
X-HE-Meta: U2FsdGVkX183C80JzklQEIa+kgNTjJZOknF6vAmyswd98TyGVgTRC8SyVWsz19w9BPwppSUtPiaeZPJXrIQbsy98gLBfQ1cJQl7yzp34fic0gzv0s9hrB6mxeJXqinMntnlfXe73gJIH/D2pt50tZwbP93X5621Z+n1JPgBDPeg2Qqz5v4YTHrFVzIaZ3VcUXUAKuj/7BGAd4D8VuUGw+dkVUMzvtoZoN/seDFwcReGQTYquH+YMzJ815xl7wR46FpiJ9+THR6XRxVuJCVh6iJAhD/ahytYNQMcMNmgFRXblBTPxbXFH63lW5Djcit4yMB+uNazqknvOnTkAw3vbLAB4CMkaAooU09WOrb4dRD5m5BQTaIQKdR+GIKMYTEwoPVIlbOYXwm+XOsikcSvwWkIxSgSJzlVeOeQCU6+wcUsByy327CPzOKFxszsj4v/QYc8SsHkTU40=



On June 21, 2026 2:08:37 PM GMT+01:00, Yury Norov <yury=2Enorov@gmail=2Eco=
m> wrote:
>On Sun, Jun 21, 2026 at 05:34:31AM -0400, Steven Rostedt wrote:
>> From: Steven Rostedt <rostedt@goodmis=2Eorg>
>>=20
>> In order to remove the include to trace_printk=2Eh from kernel=2Eh the =
tracing
>> control prototypes need to be moved back into kernel=2Eh=2E That's beca=
use
>
>Please don't=2E Instead, you can split them out to trace_control=2Eh, and
>include where needed=2E I actually have a prototype for it, FYI:
>
>https://github=2Ecom/norov/linux/tree/trace_pritk3
>

Sure, I have no problem adding another header for this=2E

>> they are used in other common header files like rcu=2Eh=2E There's no p=
oint in
>> removing trace_printk=2Eh from kernel=2Eh if it just gets added back to=
 other
>> common headers=2E
>>=20
>> Prototypes are very cheap for the compiler and should not be an issue=
=2E
>
>It's not about cost, it's about mess=2E kernel=2Eh is included everywhere=
=2E
>Is that API needed everywhere? No, it's needed in literally 10 files=2E
>So, no place in kernel=2Eh=2E
>=20

Well one of those files is rcu=2Eh which is also pretty much included ever=
ywhere=2E But OK=2E

-- Steve=20


>>=20
>> 2=2E53=2E0
>>=20
